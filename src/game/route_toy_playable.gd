class_name RouteToyPlayable
extends Node2D


const SPEED_PRESETS: Dictionary = {
	"pause": 0.0,
	"1x": 1.0,
	"2x": 2.0,
	"4x": 4.0,
}

var world: WorldMap
var graph: TrackGraph
var renderer: TrackRenderer

# Legacy single-train/route accessors (delegate to arrays)
var train: TrainEntity:
	get:
		return owned_trains[0] if not owned_trains.is_empty() else null
var runner: RouteRunner:
	get:
		return active_runners[0] if not active_runners.is_empty() else null

var owned_trains: Array[TrainEntity] = []
var active_runners: Array[RouteRunner] = []

# Stable instance ID tracking
var train_by_instance_id: Dictionary = {}   # instance_id -> TrainEntity
var route_by_instance_id: Dictionary = {}   # instance_id -> RouteRunner
var _next_train_instance_id: int = 1
var _next_route_instance_id: int = 1

var train_data: TrainData
var pathfinder: TrainPathfinder

var clock: SimulationClock
var economy: EconomyTickSystem
var schedule: RouteSchedule

var treasury: TreasuryState
var city_runtime: Dictionary = {}
var city_data_by_id: Dictionary = {}
var cargo_catalog: Dictionary = {}
var cities_grid: Dictionary = {}

var placer: TrackPlacer
var preview: TrackPlacementPreview

var _catalog: DataCatalog
var _starting_capital: int = 0


func _ready() -> void:
	_catalog = DataCatalog.new()
	_load_cities()
	_build_cargo_catalog()

	_setup_world()
	_setup_track()          # empty graph
	_setup_cities_runtime()
	_setup_treasury()
	_setup_clock()
	_setup_economy()
	_setup_track_placer()

	_auto_start()


# ------------------------------------------------------------------------------
# Public controls
# ------------------------------------------------------------------------------

func start_route() -> void:
	if runner == null:
		_show_toast("Create a route first")
		return
	var state_name := runner.get_state_name()
	if state_name == "IDLE":
		runner.start_route()
		# Auto-resume clock at 1x so economy ticks advance
		if clock != null and clock.is_paused:
			set_speed_preset("1x")
	elif state_name in ["LOADING_AT_ORIGIN", "MOVING_TO_DESTINATION", "UNLOADING_AT_DESTINATION", "RETURNING_TO_ORIGIN"]:
		_show_toast("Route already running")
	else:
		_show_toast("Route cannot start from state: %s" % state_name)


func pause_resume() -> void:
	if clock == null:
		return
	if clock.is_paused:
		clock.resume()
	else:
		clock.pause()


func set_speed_preset(preset: String) -> void:
	if clock == null:
		return
	if preset == "pause":
		clock.pause()
	else:
		var speed: float = SPEED_PRESETS.get(preset, 1.0)
		clock.set_speed(speed)
		clock.resume()


func advance_one_day() -> void:
	if clock == null:
		return
	clock.advance_one_day()


func reset_simulation() -> void:
	if clock == null:
		return

	# Stop and remove all runners
	for r in active_runners:
		if r != null:
			r.stop_route()
			r.queue_free()
	active_runners.clear()
	route_by_instance_id.clear()
	_next_route_instance_id = 1

	# Remove all trains
	for t in owned_trains:
		if t != null:
			if t.get_parent() != null:
				t.get_parent().remove_child(t)
			t.queue_free()
	owned_trains.clear()
	train_by_instance_id.clear()
	_next_train_instance_id = 1

	# Clear graph
	if graph != null:
		graph.clear()
	if renderer != null:
		renderer.queue_redraw()

	# Reset clock
	clock.pause()
	clock.current_day = 1
	clock.current_month = 1
	clock.current_year = 1857
	clock._accumulator = 0.0

	# Reset economy/cities/treasury
	_setup_cities_runtime()
	_setup_treasury()

	# Turn off build mode
	if placer != null:
		placer.set_build_mode(false)

	# Close any open panels
	var hud = $HUD
	if hud != null:
		if hud.has_method("close_panels"):
			hud.close_panels()
		if hud.has_method("bind_route_toy"):
			hud.bind_route_toy(self)

	_show_toast("Simulation reset")


# ------------------------------------------------------------------------------
# Player agency: Build Track
# ------------------------------------------------------------------------------

func toggle_build_mode() -> void:
	if placer == null:
		return
	var active := not placer._build_mode_active
	placer.set_build_mode(active)
	_show_toast("Build Track: ON" if active else "Build Track: OFF")


# ------------------------------------------------------------------------------
# Player agency: Train Purchase
# ------------------------------------------------------------------------------

func purchase_train(train_id: String, city_id: String) -> bool:
	var t_data: TrainData = _catalog.get_train_by_id(train_id)
	if t_data == null:
		_show_toast("Unknown train type")
		return false

	if not treasury.can_afford(t_data.cost):
		_show_toast("Insufficient funds — need ₹%s" % _comma_sep(t_data.cost))
		return false

	if not cities_grid.has(city_id):
		_show_toast("Unknown city: %s" % city_id)
		return false

	treasury.spend(t_data.cost)

	# Create pathfinder (shared per train, but each train needs its own)
	var pf := TrainPathfinder.new()
	pf.setup(graph)

	var train_scene := preload("res://scenes/trains/train_entity.tscn")
	var t := train_scene.instantiate() as TrainEntity
	t.setup(t_data, pf)
	world.add_child(t)

	var train_cargo: TrainCargo = t.get_train_cargo()
	if train_cargo != null:
		train_cargo.setup_from_train_data(t_data, cargo_catalog)

	t.reset_to(cities_grid[city_id])

	# Assign stable instance ID
	t.instance_id = "train_%03d" % _next_train_instance_id
	_next_train_instance_id += 1
	train_by_instance_id[t.instance_id] = t

	owned_trains.append(t)

	_show_toast("Purchased %s (%s) at %s — ₹%s" % [t_data.display_name, t.instance_id, city_data_by_id[city_id].display_name, _comma_sep(t_data.cost)])
	return true


# ------------------------------------------------------------------------------
# Player agency: Route Creation
# ------------------------------------------------------------------------------

func create_route(params: Dictionary) -> bool:
	var train_idx: int = params.get("train_index", 0)
	var origin_id: String = params.get("origin_city_id", "")
	var destination_id: String = params.get("destination_city_id", "")
	var cargo_id: String = params.get("cargo_id", "")
	var loop: bool = params.get("loop_enabled", true)
	var return_empty: bool = params.get("return_empty", true)

	if train_idx < 0 or train_idx >= owned_trains.size():
		_show_toast("Invalid train selected")
		return false

	var t: TrainEntity = owned_trains[train_idx]
	var t_data: TrainData = t.train_data

	if not city_runtime.has(origin_id) or not city_runtime.has(destination_id):
		_show_toast("Invalid city selection")
		return false

	if origin_id == destination_id:
		_show_toast("Origin and destination must be different")
		return false

	# Validate path exists
	var origin_grid: Vector2i = cities_grid[origin_id]
	var destination_grid: Vector2i = cities_grid[destination_id]
	if graph == null or not graph.has_node(origin_grid) or not graph.has_node(destination_grid):
		_show_toast("No track connection between cities")
		return false
	var path_result: TrackPathResult = graph.find_path(origin_grid, destination_grid)
	if not path_result.success:
		_show_toast("No track connection between cities")
		return false

	var new_schedule := RouteSchedule.new()
	new_schedule.instance_id = "route_%03d" % _next_route_instance_id
	new_schedule.assigned_train_instance_id = t.instance_id
	new_schedule.route_id = "%s_to_%s_%s" % [origin_id, destination_id, cargo_id]
	new_schedule.origin_city_id = origin_id
	new_schedule.destination_city_id = destination_id
	new_schedule.cargo_id = cargo_id
	new_schedule.loop_enabled = loop
	new_schedule.return_empty = return_empty

	var new_runner := RouteRunner.new()
	new_runner.setup(
		new_schedule,
		t,
		t_data,
		graph,
		city_runtime[origin_id],
		city_runtime[destination_id],
		city_data_by_id[origin_id],
		city_data_by_id[destination_id],
		treasury,
		cargo_catalog
	)
	add_child(new_runner)
	active_runners.append(new_runner)
	route_by_instance_id[new_schedule.instance_id] = new_runner
	_next_route_instance_id += 1

	# Auto-start the route
	new_runner.start_route()
	if clock != null and clock.is_paused:
		set_speed_preset("1x")

	_show_toast("Route created: %s → %s (%s)" % [
		city_data_by_id[origin_id].display_name,
		city_data_by_id[destination_id].display_name,
		cargo_id
	])

	# Re-bind HUD signals to the new runner
	var hud = $HUD
	if hud != null and hud.has_method("bind_route_toy"):
		hud.bind_route_toy(self)

	return true


# ------------------------------------------------------------------------------
# Queries for HUD
# ------------------------------------------------------------------------------

func get_treasury_balance() -> int:
	return treasury.balance if treasury != null else 0


func get_date_string() -> String:
	return clock.get_date_string() if clock != null else "—"


func is_clock_paused() -> bool:
	return clock.is_paused if clock != null else true


func get_runner_state_name() -> String:
	return runner.get_state_name() if runner != null else "No route"


func get_runner_stats() -> RouteProfitStats:
	return runner.get_stats() if runner != null else null


func get_runner_by_index(index: int) -> RouteRunner:
	if index < 0 or index >= active_runners.size():
		return null
	return active_runners[index]


func get_runner_count() -> int:
	return active_runners.size()


func get_train_by_instance_id(id: String) -> TrainEntity:
	return train_by_instance_id.get(id, null) as TrainEntity


func get_route_schedule_by_index(index: int) -> RouteSchedule:
	var r: RouteRunner = get_runner_by_index(index)
	if r == null:
		return null
	return r._schedule


func get_city_stock(city_id: String, cargo_id: String) -> int:
	var runtime: CityRuntimeState = city_runtime.get(city_id)
	if runtime == null:
		return 0
	return runtime.get_quantity(cargo_id)


func get_sell_price(city_id: String, cargo_id: String) -> float:
	var runtime: CityRuntimeState = city_runtime.get(city_id)
	var city_data: CityData = city_data_by_id.get(city_id)
	if runtime == null or city_data == null:
		return 0.0
	return MarketPricing.get_sell_price(cargo_id, runtime, city_data, cargo_catalog)


func get_demand_label(city_id: String, cargo_id: String) -> String:
	var price := get_sell_price(city_id, cargo_id)
	var city_data: CityData = city_data_by_id.get(city_id)
	if city_data == null:
		return "—"
	var cargo: CargoData = cargo_catalog.get(cargo_id, null) as CargoData
	if cargo == null:
		return "—"
	var ratio := price / cargo.base_price
	if ratio > 1.2:
		return "Shortage"
	elif ratio < 0.8:
		return "Oversupplied"
	return "Balanced"


func get_train_display_names() -> Array[String]:
	var result: Array[String] = []
	for t in owned_trains:
		if t != null and t.train_data != null:
			result.append(t.train_data.display_name)
		else:
			result.append("Unknown")
	return result


func get_city_display_names() -> Dictionary:
	var result := {}
	for city_id in city_data_by_id.keys():
		var data: CityData = city_data_by_id[city_id]
		result[city_id] = data.display_name if data != null else city_id
	return result


func get_cargo_ids() -> Array[String]:
	var result: Array[String] = []
	for cargo_id in cargo_catalog.keys():
		result.append(cargo_id)
	return result


func get_train_catalog() -> Dictionary:
	var result := {}
	for train_id in ["freight_engine", "mixed_engine"]:
		var t_data: TrainData = _catalog.get_train_by_id(train_id)
		if t_data != null:
			result[train_id] = t_data
	return result


func get_path_estimate(origin_city_id: String, destination_city_id: String, train_index: int = 0, cargo_id: String = "coal") -> Dictionary:
	var result := {
		"valid": false,
		"distance_km": 0.0,
		"revenue_estimate": 0,
		"maintenance_per_day": 0,
		"train_capacity_units": 0,
		"origin_stock": 0,
		"dest_price": 0.0,
		"demand_ratio": 1.0,
	}
	if not cities_grid.has(origin_city_id) or not cities_grid.has(destination_city_id):
		return result
	var origin_grid: Vector2i = cities_grid[origin_city_id]
	var dest_grid: Vector2i = cities_grid[destination_city_id]
	if graph == null or not graph.has_node(origin_grid) or not graph.has_node(dest_grid):
		return result
	var path_result: TrackPathResult = graph.find_path(origin_grid, dest_grid)
	if not path_result.success:
		return result

	result.valid = true
	result.distance_km = path_result.total_length_km

	# Train capacity
	var t: TrainEntity = null
	if train_index >= 0 and train_index < owned_trains.size():
		t = owned_trains[train_index]
	var t_data: TrainData = t.train_data if t != null else null
	var cargo: CargoData = cargo_catalog.get(cargo_id, null) as CargoData
	if t_data != null and cargo != null and cargo.weight_per_unit > 0:
		result.train_capacity_units = int(floorf(t_data.capacity_tons / cargo.weight_per_unit))
		result.maintenance_per_day = t_data.maintenance_per_day

	# Market data
	result.dest_price = get_sell_price(destination_city_id, cargo_id)
	result.revenue_estimate = int(result.train_capacity_units * result.dest_price)
	result.origin_stock = get_city_stock(origin_city_id, cargo_id)

	var city_data: CityData = city_data_by_id.get(destination_city_id, null) as CityData
	if city_data != null and cargo != null:
		var profile: CityCargoProfileData = _find_profile(city_data, cargo_id)
		if profile != null and profile.target_stock > 0:
			var dest_stock: int = get_city_stock(destination_city_id, cargo_id)
			result.demand_ratio = float(dest_stock) / float(profile.target_stock)

	return result


func _find_profile(city_data: CityData, cargo_id: String) -> CityCargoProfileData:
	for profile in city_data.cargo_profiles:
		if profile != null and profile.cargo_id == cargo_id:
			return profile
	return null


# ------------------------------------------------------------------------------
# Setup helpers
# ------------------------------------------------------------------------------

func _load_cities() -> void:
	for city_id in ["kolkata", "patna", "dacca", "murshidabad"]:
		var city := _catalog.get_city_by_id(city_id)
		if city != null:
			cities_grid[city_id] = city.map_position
			city_data_by_id[city_id] = city


func _build_cargo_catalog() -> void:
	for cargo in _catalog.cargos:
		cargo_catalog[cargo.cargo_id] = cargo


func _setup_world() -> void:
	var world_scene := preload("res://scenes/world/world.tscn")
	world = world_scene.instantiate() as WorldMap
	add_child(world)


func _setup_track() -> void:
	graph = TrackGraph.new()
	renderer = TrackRenderer.new()
	renderer.setup(graph)
	world.add_child(renderer)


func _setup_cities_runtime() -> void:
	city_runtime.clear()
	for city_id in ["kolkata", "patna", "dacca", "murshidabad"]:
		var city_data: CityData = _catalog.get_city_by_id(city_id)
		if city_data == null:
			continue
		var runtime := CityRuntimeState.new()
		runtime.setup_from_city_data(city_data, cargo_catalog)
		city_runtime[city_id] = runtime


func _setup_treasury() -> void:
	var faction: FactionData = _catalog.get_faction_by_id("player_railway_company")
	_starting_capital = faction.starting_capital if faction != null else 50000
	treasury = TreasuryState.new(_starting_capital)


func _setup_clock() -> void:
	clock = SimulationClock.new()
	add_child(clock)


func _setup_economy() -> void:
	economy = EconomyTickSystem.new()
	economy.setup(city_runtime, city_data_by_id, cargo_catalog)
	add_child(economy)
	clock.day_passed.connect(economy.tick_day)
	clock.day_passed.connect(_on_day_passed)


func _setup_track_placer() -> void:
	preview = TrackPlacementPreview.new()
	world.add_child(preview)

	placer = TrackPlacer.new()
	placer.setup(graph, world._camera, preview, renderer)
	placer.set_treasury(treasury)

	var city_coords: Array[Vector2i] = []
	for city_id in cities_grid.keys():
		city_coords.append(cities_grid[city_id])
	placer.set_city_coords(city_coords)
	placer.set_on_toast(_show_toast)
	add_child(placer)


func _auto_start() -> void:
	clock.start()
	clock.pause()  # Start paused — player drives the action

	var hud = $HUD
	if hud != null and hud.has_method("bind_route_toy"):
		hud.bind_route_toy(self)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			save_game()
		elif event.keycode == KEY_F9:
			load_game()


func save_game() -> bool:
	var ok := SaveLoadService.save_game(self)
	if ok:
		_show_save_toast("Game Saved")
	else:
		_show_save_toast("Save Failed")
	return ok


func load_game() -> bool:
	var ok := SaveLoadService.load_game(self)
	if ok:
		_show_save_toast("Game Loaded")
		# Re-bind HUD signals after load
		var hud = $HUD
		if hud != null and hud.has_method("bind_route_toy"):
			hud.bind_route_toy(self)
		# Restart all idle routes
		for r in active_runners:
			if r != null and r.get_state_name() == "IDLE":
				r.start_route()
	else:
		_show_save_toast("Load Failed")
	return ok


func _show_toast(message: String) -> void:
	_show_save_toast(message)


func _show_save_toast(message: String) -> void:
	var hud = $HUD
	if hud != null and hud.has_method("show_toast"):
		hud.show_toast(message)
	else:
		print("Toast: %s" % message)


func _on_day_passed(_day: int, _month: int, _year: int) -> void:
	for r in active_runners:
		if r != null:
			r.on_day_passed()


static func _comma_sep(n: int) -> String:
	var s := str(n)
	var result := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result
