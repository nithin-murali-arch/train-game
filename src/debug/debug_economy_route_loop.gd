class_name DebugEconomyRouteLoop
extends Node


const CITY_EDGES: Array[Array] = [
	["kolkata", "patna"],
	["kolkata", "murshidabad"],
	["murshidabad", "dacca"],
	["patna", "dacca"],
]

var _world: WorldMap
var _graph: TrackGraph
var _renderer: TrackRenderer
var _train: TrainEntity
var _train_data: TrainData
var _catalog: DataCatalog
var _cities_grid: Dictionary = {}
var _city_runtime: Dictionary = {}
var _city_data_by_id: Dictionary = {}
var _treasury: TreasuryState
var _cargo_catalog: Dictionary = {}
var _clock: SimulationClock
var _economy: EconomyTickSystem
var _route_runner: RouteRunner


func _ready() -> void:
	_catalog = DataCatalog.new()
	_load_cities()
	_build_cargo_catalog()

	# World
	_world = preload("res://scenes/world/world.tscn").instantiate()
	add_child(_world)

	# Graph
	_graph = TrackGraph.new()
	for pair in CITY_EDGES:
		_graph.add_edge(_cities_grid[pair[0]], _cities_grid[pair[1]])

	# Renderer
	_renderer = TrackRenderer.new()
	_renderer.setup(_graph)
	_world.add_child(_renderer)

	# Runtime cities
	_build_city_runtime_states()

	# Treasury
	var faction: FactionData = _catalog.get_faction_by_id("player_railway_company")
	var starting_capital: int = faction.starting_capital if faction != null else 50000
	_treasury = TreasuryState.new(starting_capital)

	# Clock
	_clock = SimulationClock.new()
	add_child(_clock)

	# Economy tick system
	_economy = EconomyTickSystem.new()
	_economy.setup(_city_runtime, _city_data_by_id, _cargo_catalog)
	add_child(_economy)
	_clock.day_passed.connect(_economy.tick_day)
	_clock.day_passed.connect(_on_day_passed)

	# Train
	_train_data = _catalog.get_train_by_id("freight_engine")
	var train_scene := preload("res://scenes/trains/train_entity.tscn")
	_train = train_scene.instantiate() as TrainEntity
	_train.setup(_train_data, null)
	_world.add_child(_train)

	var train_cargo: TrainCargo = _train.get_train_cargo()
	if train_cargo != null:
		train_cargo.setup_from_train_data(_train_data, _cargo_catalog)

	# Route
	var schedule := RouteSchedule.new()
	schedule.route_id = "patna_to_kolkata_coal"
	schedule.origin_city_id = "patna"
	schedule.destination_city_id = "kolkata"
	schedule.cargo_id = "coal"
	schedule.loop_enabled = true
	schedule.return_empty = true

	_route_runner = RouteRunner.new()
	_route_runner.setup(
		schedule,
		_train,
		_train_data,
		_graph,
		_city_runtime["patna"],
		_city_runtime["kolkata"],
		_city_data_by_id["patna"],
		_city_data_by_id["kolkata"],
		_treasury,
		_cargo_catalog
	)
	add_child(_route_runner)

	_print_banner(starting_capital)

	# Auto-start for headless testing
	_clock.start()
	_route_runner.start_route()


func _load_cities() -> void:
	for city_id in ["kolkata", "patna", "dacca", "murshidabad"]:
		var city := _catalog.get_city_by_id(city_id)
		if city != null:
			_cities_grid[city_id] = city.map_position
			_city_data_by_id[city_id] = city


func _build_cargo_catalog() -> void:
	for cargo in _catalog.cargos:
		_cargo_catalog[cargo.cargo_id] = cargo


func _build_city_runtime_states() -> void:
	_city_runtime.clear()
	for city_id in ["kolkata", "patna", "dacca", "murshidabad"]:
		var city_data: CityData = _catalog.get_city_by_id(city_id)
		if city_data == null:
			continue
		var runtime := CityRuntimeState.new()
		runtime.setup_from_city_data(city_data, _cargo_catalog)
		_city_runtime[city_id] = runtime


func _print_banner(starting_capital: int) -> void:
	print("")
	print("ECONOMY ROUTE LOOP DEBUG")
	print("Date: %s" % _clock.get_date_string())
	print("Treasury: ₹%d" % starting_capital)
	print("")
	for city_id in ["patna", "kolkata", "murshidabad", "dacca"]:
		var runtime: CityRuntimeState = _city_runtime[city_id]
		if runtime != null:
			print("%s — coal: %d, grain: %d" % [runtime.display_name, runtime.get_quantity("coal"), runtime.get_quantity("grain")])
	print("")
	print("Controls:")
	print("  Space = pause/resume")
	print("  R = reset simulation")
	print("  D = advance one day")
	print("  1 = inspect Patna -> Kolkata coal route")
	print("  2 = inspect Murshidabad -> Dacca grain route")
	print("")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				_toggle_pause()
			KEY_R:
				_reset_all()
			KEY_D:
				_advance_one_day()
			KEY_1:
				_inspect_route("patna", "kolkata", "coal")
			KEY_2:
				_inspect_route("murshidabad", "dacca", "grain")


func _toggle_pause() -> void:
	if _clock.is_paused:
		_clock.resume()
		print("Resumed")
	else:
		_clock.pause()
		print("Paused")


func _reset_all() -> void:
	_clock.pause()
	_clock.current_day = 1
	_clock.current_month = 1
	_clock.current_year = 1857
	_clock._accumulator = 0.0

	_build_city_runtime_states()

	var faction: FactionData = _catalog.get_faction_by_id("player_railway_company")
	var starting_capital: int = faction.starting_capital if faction != null else 50000
	_treasury = TreasuryState.new(starting_capital)

	_route_runner.reset_route()
	_route_runner._treasury = _treasury
	_route_runner._origin_runtime = _city_runtime["patna"]
	_route_runner._destination_runtime = _city_runtime["kolkata"]

	print("")
	print("RESET COMPLETE")
	_print_banner(starting_capital)


func _advance_one_day() -> void:
	_clock.advance_one_day()
	print("Date: %s" % _clock.get_date_string())


func _inspect_route(origin_id: String, dest_id: String, cargo_id: String) -> void:
	var origin: CityRuntimeState = _city_runtime[origin_id]
	var dest: CityRuntimeState = _city_runtime[dest_id]
	var origin_data: CityData = _city_data_by_id[origin_id]
	var dest_data: CityData = _city_data_by_id[dest_id]
	if origin == null or dest == null:
		return

	var price := MarketPricing.get_sell_price(cargo_id, dest, dest_data, _cargo_catalog)
	print("")
	print("Route inspection: %s -> %s (%s)" % [origin_data.display_name, dest_data.display_name, cargo_id])
	print("  %s stock: %d" % [origin_data.display_name, origin.get_quantity(cargo_id)])
	print("  %s stock: %d" % [dest_data.display_name, dest.get_quantity(cargo_id)])
	print("  Dynamic sell price at %s: ₹%.0f" % [dest_data.display_name, price])
	print("")


func _on_day_passed(_day: int, _month: int, _year: int) -> void:
	_route_runner.on_day_passed()
