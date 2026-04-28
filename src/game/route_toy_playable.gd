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

# Sprint 14: Economy Depth
var reputation: int = 0
var contract_manager: ContractManager
var station_upgrades: Dictionary = {}  # city_id -> StationUpgradeState

# Sprint 15: Faction & AI systems
var faction_manager: FactionManager = null
var delivery_ledger: DeliveryLedger = null
var market_share: MarketShareSystem = null
var baron_ai: BaronAI = null
var ai_trains: Array[TrainEntity] = []
var ai_runners: Array[RouteRunner] = []

# Sprint 16: Events
var event_manager: EventManager = null

# Sprint 17: Faction selection
var selected_faction_id: String = "british"

# Sprint 17: Audio
var audio_manager: AudioManager = null

# Sprint 17: Campaign / Scenario
var campaign_manager: CampaignManager = null
var scenario_data: ScenarioData = null

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
	# Check GameState for menu-driven selections (campaign/scenario/faction)
	var gs := get_node_or_null("/root/GameState")
	if gs != null:
		var faction_id = gs.get_meta("selected_faction_id", "")
		if not faction_id.is_empty():
			selected_faction_id = faction_id

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
	_setup_contracts()
	_setup_faction_systems()
	_setup_baron_ai()
	_setup_station_upgrades()
	_setup_events()
	_setup_audio()
	_setup_campaign_manager()

	_auto_start()


# ------------------------------------------------------------------------------
# Public controls
# ------------------------------------------------------------------------------

func start_route() -> void:
	if audio_manager != null:
		audio_manager.play_click()
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
	if audio_manager != null:
		audio_manager.play_click()
	if clock == null:
		return
	if clock.is_paused:
		clock.resume()
	else:
		clock.pause()


func set_speed_preset(preset: String) -> void:
	if audio_manager != null:
		audio_manager.play_click()
	if clock == null:
		return
	if preset == "pause":
		clock.pause()
	else:
		var speed: float = SPEED_PRESETS.get(preset, 1.0)
		clock.set_speed(speed)
		clock.resume()


func advance_one_day() -> void:
	if audio_manager != null:
		audio_manager.play_click()
	if clock == null:
		return
	clock.advance_one_day()


func reset_simulation(mode: String = "sandbox") -> void:
	if audio_manager != null:
		audio_manager.play_click()
	if clock == null:
		return

	# Preserve campaign manager for campaign mode
	var preserved_campaign: CampaignManager = null
	if mode == "campaign" and campaign_manager != null:
		preserved_campaign = campaign_manager
		remove_child(campaign_manager)

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

	# Stop and remove all AI runners
	for r in ai_runners:
		if r != null:
			r.stop_route()
			r.queue_free()
	ai_runners.clear()

	# Remove all AI trains
	for t in ai_trains:
		if t != null:
			if t.get_parent() != null:
				t.get_parent().remove_child(t)
			t.queue_free()
	ai_trains.clear()

	# Remove old event manager
	if event_manager != null:
		event_manager.queue_free()
		event_manager = null

	# Remove old campaign manager (unless preserved)
	if campaign_manager != null and campaign_manager != preserved_campaign:
		campaign_manager.queue_free()
		campaign_manager = null

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
	_setup_faction_systems()
	_setup_baron_ai()
	_setup_events()

	# Re-wire placer to new treasury and faction manager
	if placer != null:
		placer.set_treasury(treasury)
		placer.set_faction_manager(faction_manager)

	# Reset Sprint 14 state
	reputation = 0
	contract_manager = ContractManager.new()
	contract_manager.setup(city_data_by_id, cargo_catalog, treasury)
	contract_manager.set_faction_manager(faction_manager)
	station_upgrades.clear()
	for city_id in city_data_by_id.keys():
		station_upgrades[city_id] = StationUpgradeState.new()

	# Turn off build mode
	if placer != null:
		placer.set_build_mode(false)

	# Close any open panels
	var hud = get_node_or_null("HUD")
	if hud != null:
		if hud.has_method("close_panels"):
			hud.close_panels()
		if hud.has_method("bind_route_toy"):
			hud.bind_route_toy(self)

	if mode == "scenario" and scenario_data != null:
		_apply_scenario_starting_conditions()
		_show_toast("Scenario reset")
	elif mode == "campaign":
		if preserved_campaign != null:
			campaign_manager = preserved_campaign
			add_child(campaign_manager)
		_show_toast("Campaign reset")
	else:
		scenario_data = null
		campaign_manager = null
		_show_toast("Simulation reset")


# ------------------------------------------------------------------------------
# Player agency: Build Track
# ------------------------------------------------------------------------------

func toggle_build_mode() -> void:
	if audio_manager != null:
		audio_manager.play_click()
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

	if faction_manager == null or not faction_manager.can_afford(FactionManager.FACTION_PLAYER, t_data.cost):
		_show_toast("Insufficient funds — need ₹%s" % _comma_sep(t_data.cost))
		return false

	if not cities_grid.has(city_id):
		_show_toast("Unknown city: %s" % city_id)
		return false

	faction_manager.spend_money(FactionManager.FACTION_PLAYER, t_data.cost)
	# treasury is the same object reference, already in sync

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

	if audio_manager != null:
		audio_manager.play_cash()

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
		cargo_catalog,
		get_maintenance_discount_for_city,
		FactionManager.FACTION_PLAYER,
		faction_manager,
		delivery_ledger
	)
	add_child(new_runner)
	active_runners.append(new_runner)
	route_by_instance_id[new_schedule.instance_id] = new_runner
	_next_route_instance_id += 1

	# Connect contract delivery tracking
	new_runner.trip_completed.connect(_on_trip_completed)

	# Auto-start the route
	new_runner.start_route()
	if clock != null and clock.is_paused:
		set_speed_preset("1x")

	if audio_manager != null:
		audio_manager.play_confirm()

	_show_toast("Route created: %s → %s (%s)" % [
		city_data_by_id[origin_id].display_name,
		city_data_by_id[destination_id].display_name,
		cargo_id
	])

	# Re-bind HUD signals to the new runner
	var hud = get_node_or_null("HUD")
	if hud != null and hud.has_method("bind_route_toy"):
		hud.bind_route_toy(self)

	return true


func create_ai_route(schedule: RouteSchedule, train: TrainEntity, train_data: TrainData) -> RouteRunner:
	if not city_runtime.has(schedule.origin_city_id) or not city_runtime.has(schedule.destination_city_id):
		return null

	var new_runner := RouteRunner.new()
	new_runner.setup(
		schedule,
		train,
		train_data,
		graph,
		city_runtime[schedule.origin_city_id],
		city_runtime[schedule.destination_city_id],
		city_data_by_id[schedule.origin_city_id],
		city_data_by_id[schedule.destination_city_id],
		faction_manager.get_treasury_for_faction(FactionManager.FACTION_BRITISH),
		cargo_catalog,
		get_maintenance_discount_for_city,
		FactionManager.FACTION_BRITISH,
		faction_manager,
		delivery_ledger
	)
	add_child(new_runner)
	ai_runners.append(new_runner)

	# Connect trip tracking
	new_runner.trip_completed.connect(_on_trip_completed)

	return new_runner


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


func get_british_treasury_balance() -> int:
	if faction_manager == null:
		return 0
	return faction_manager.get_balance(FactionManager.FACTION_BRITISH)


func get_player_market_share() -> float:
	if market_share == null:
		return 0.0
	return market_share.get_overall_market_share(FactionManager.FACTION_PLAYER)


func get_city_market_share(city_id: String) -> float:
	if market_share == null:
		return 0.0
	return market_share.get_city_market_share(city_id, FactionManager.FACTION_PLAYER)


func get_ai_state_name() -> String:
	if baron_ai == null:
		return "No AI"
	return baron_ai.get_state_name()


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
	var base_capital: int = faction.starting_capital if faction != null else 50000

	var starting_capital := base_capital
	match selected_faction_id:
		"british":
			starting_capital = 60000
		"french":
			starting_capital = 50000
		"amdani":
			starting_capital = 45000

	faction_manager = FactionManager.new()
	var bonuses := AvailableFactions.get_all_bonuses_for_faction(selected_faction_id)
	faction_manager.setup(starting_capital, 50000, bonuses)
	treasury = faction_manager.get_treasury_for_faction(FactionManager.FACTION_PLAYER)


func _setup_faction_systems() -> void:
	delivery_ledger = DeliveryLedger.new()
	market_share = MarketShareSystem.new()
	market_share.setup(delivery_ledger)


func _setup_baron_ai() -> void:
	baron_ai = BaronAI.new()
	baron_ai.setup(graph, faction_manager, city_runtime, city_data_by_id, cargo_catalog, cities_grid, world, _catalog, get_maintenance_discount_for_city)
	add_child(baron_ai)


func _setup_events() -> void:
	event_manager = EventManager.new()
	event_manager.setup(city_data_by_id, graph, city_runtime, treasury)
	add_child(event_manager)


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
	placer.set_faction_manager(faction_manager)

	var city_coords: Array[Vector2i] = []
	for city_id in cities_grid.keys():
		city_coords.append(cities_grid[city_id])
	placer.set_city_coords(city_coords)
	placer.set_on_toast(_show_toast)
	add_child(placer)


func _setup_contracts() -> void:
	contract_manager = ContractManager.new()
	contract_manager.setup(city_data_by_id, cargo_catalog, treasury, func(new_rep: int): reputation = new_rep)
	contract_manager.set_faction_manager(faction_manager)
	# Generate initial contracts
	if clock != null:
		contract_manager.generate_contracts_if_needed(clock.current_day, clock.current_month, clock.current_year)


func _setup_station_upgrades() -> void:
	station_upgrades.clear()
	for city_id in city_data_by_id.keys():
		station_upgrades[city_id] = StationUpgradeState.new()


func _auto_start() -> void:
	clock.start()
	clock.pause()  # Start paused — player drives the action

	var hud = get_node_or_null("HUD")
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
		var hud = get_node_or_null("HUD")
		if hud != null and hud.has_method("bind_route_toy"):
			hud.bind_route_toy(self)
		# Reconnect contract tracking signals
		for r in active_runners:
			if r != null and not r.trip_completed.is_connected(_on_trip_completed):
				r.trip_completed.connect(_on_trip_completed)

		# Restart all idle routes
		for r in active_runners:
			if r != null and r.get_state_name() == "IDLE":
				r.start_route()
	else:
		_show_save_toast("Load Failed")
	return ok


func _show_toast(message: String) -> void:
	if audio_manager != null and message.contains("Insufficient"):
		audio_manager.play_error()
	_show_save_toast(message)


func _show_save_toast(message: String) -> void:
	var hud = get_node_or_null("HUD")
	if hud != null and hud.has_method("show_toast"):
		hud.show_toast(message)
	else:
		print("Toast: %s" % message)


func _on_trip_completed(stats: RouteProfitStats) -> void:
	if stats == null:
		return
	if audio_manager != null:
		audio_manager.play_train_arrive()

	# Find the runner that emitted this signal
	var found_runner: RouteRunner = null
	var faction_id: String = ""
	for r in active_runners + ai_runners:
		if r != null and r.get_stats() == stats and r._schedule != null:
			found_runner = r
			faction_id = FactionManager.FACTION_BRITISH if r in ai_runners else FactionManager.FACTION_PLAYER
			break

	if found_runner == null:
		return

	var sched: RouteSchedule = found_runner._schedule

	# Record to delivery ledger
	if delivery_ledger != null and clock != null:
		var absolute_day := _to_absolute_day(clock.current_day, clock.current_month, clock.current_year)
		delivery_ledger.record_delivery(
			absolute_day,
			faction_id,
			sched.instance_id,
			sched.assigned_train_instance_id,
			sched.origin_city_id,
			sched.destination_city_id,
			sched.cargo_id,
			stats.last_trip_quantity,
			stats.last_trip_revenue,
			stats.last_trip_operating_cost
		)

	# Sprint 14: forward delivery to contract manager (only for player routes)
	if contract_manager != null and faction_id == FactionManager.FACTION_PLAYER:
		contract_manager.record_delivery(sched.cargo_id, sched.destination_city_id, stats.last_trip_quantity)


func _on_day_passed(day: int, month: int, year: int) -> void:
	for r in active_runners:
		if r != null:
			r.on_day_passed()

	# Sprint 15: Baron AI tick
	if baron_ai != null:
		baron_ai.tick(day, month, year)

	# Sprint 16: Event manager tick
	if event_manager != null:
		event_manager.tick(day, month, year)

	# Set current day on all runners for ledger recording
	for r in active_runners + ai_runners:
		if r != null and r.has_method("set_current_day"):
			r.set_current_day(day, month, year)

	# Sprint 14: contract deadlines and generation
	if contract_manager != null:
		contract_manager.check_deadlines(day, month, year)
		contract_manager.generate_contracts_if_needed(day, month, year)

	# Sprint 17: Campaign objective tick
	if campaign_manager != null:
		campaign_manager.tick_objectives(self)

	# Pass event state to HUD
	var hud = get_node_or_null("HUD")
	if hud != null and hud.has_method("update_events"):
		hud.update_events(get_warning_events(), get_active_events())


func get_warning_events() -> Array[EventRuntimeState]:
	if event_manager == null:
		return []
	return event_manager.get_warning_events()


func get_active_events() -> Array[EventRuntimeState]:
	if event_manager == null:
		return []
	return event_manager.get_active_events()


func repair_track_edge(from: Vector2i, to: Vector2i) -> bool:
	if graph == null:
		return false
	var edge := graph.get_edge(from, to)
	if edge == null:
		return false
	var repair := TrackRepair.new()
	if not repair.can_repair(edge, treasury):
		return false
	return repair.repair_edge(edge, treasury)


func get_maintenance_discount_for_city(city_id: String) -> float:
	var upgrades: StationUpgradeState = station_upgrades.get(city_id, null) as StationUpgradeState
	if upgrades == null:
		return 0.0
	return upgrades.get_maintenance_discount()


func _to_absolute_day(day: int, month: int, year: int) -> int:
	return ((year - 1857) * 360) + ((month - 1) * 30) + day


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


# ------------------------------------------------------------------------------
# Sprint 17: Audio
# ------------------------------------------------------------------------------

func _setup_audio() -> void:
	audio_manager = AudioManager.new()
	add_child(audio_manager)


# ------------------------------------------------------------------------------
# Sprint 17: Campaign / Scenario / Sandbox
# ------------------------------------------------------------------------------

func _setup_campaign_manager() -> void:
	# Campaign manager is created on demand via start_campaign()
	campaign_manager = null


func start_campaign(campaign_id: String) -> void:
	reset_simulation("campaign")
	campaign_manager = CampaignManager.new()
	match campaign_id:
		"bengal_railway_charter":
			campaign_manager.current_campaign = BengalRailwayCharter.create_campaign()
	campaign_manager.start_campaign(campaign_id)
	add_child(campaign_manager)
	_show_toast("Campaign started: %s" % campaign_manager.current_campaign.display_name)


func start_scenario(scenario_id: String) -> void:
	reset_simulation("scenario")
	match scenario_id:
		"bengal_charter":
			scenario_data = Scenarios.create_bengal_charter_scenario()
		"port_monopoly":
			scenario_data = Scenarios.create_port_monopoly_scenario()
		"monsoon_crisis":
			scenario_data = Scenarios.create_monsoon_crisis_scenario()
	_apply_scenario_starting_conditions()
	if scenario_data != null:
		_show_toast("Scenario started: %s" % scenario_data.display_name)
	else:
		_show_toast("Unknown scenario: %s" % scenario_id)


func start_sandbox() -> void:
	reset_simulation("sandbox")
	_show_toast("Sandbox mode started")


func _apply_scenario_starting_conditions() -> void:
	if scenario_data == null:
		return

	# Starting money
	if scenario_data.starting_money > 0 and faction_manager != null:
		var player_treasury := faction_manager.get_treasury_for_faction(FactionManager.FACTION_PLAYER)
		if player_treasury != null:
			player_treasury.balance = scenario_data.starting_money
			treasury = player_treasury

	# Prebuilt track
	for track in scenario_data.prebuilt_track:
		var from_id: String = track.get("from", "") as String
		var to_id: String = track.get("to", "") as String
		if cities_grid.has(from_id) and cities_grid.has(to_id):
			if graph != null:
				var from_grid: Vector2i = cities_grid[from_id]
				var to_grid: Vector2i = cities_grid[to_id]
				if not graph.has_node(from_grid):
					graph.add_node(from_grid)
				if not graph.has_node(to_grid):
					graph.add_node(to_grid)
				graph.add_edge(from_grid, to_grid, FactionManager.FACTION_PLAYER)
	if renderer != null:
		renderer.setup(graph)

	# Starting trains
	for train_info in scenario_data.starting_trains:
		var t_id: String = train_info.get("train_id", "") as String
		var t_city: String = train_info.get("city_id", "") as String
		if not t_id.is_empty() and not t_city.is_empty():
			purchase_train(t_id, t_city)


func get_campaign_state_name() -> String:
	if campaign_manager != null and campaign_manager.current_campaign != null:
		var act := campaign_manager.get_current_act()
		var act_name := act.display_name if act != null else "Act %d" % (campaign_manager.current_act_index + 1)
		return "%s: %s" % [campaign_manager.current_campaign.display_name, act_name]
	if scenario_data != null:
		return "Scenario: %s" % scenario_data.display_name
	return "Sandbox"
