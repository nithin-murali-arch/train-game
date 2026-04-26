class_name DebugCargoTransaction
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
var _pathfinder: TrainPathfinder
var _catalog: DataCatalog
var _cities_grid: Dictionary = {}      # city_id -> Vector2i
var _city_runtime: Dictionary = {}     # city_id -> CityRuntimeState
var _treasury: TreasuryState
var _arrival_handler: StationArrivalHandler
var _cargo_catalog: Dictionary = {}
var _train_data: TrainData


func _ready() -> void:
	_catalog = DataCatalog.new()
	_load_cities()
	_build_cargo_catalog()

	# Instance world
	_world = preload("res://scenes/world/world.tscn").instantiate()
	add_child(_world)

	# Build graph
	_graph = TrackGraph.new()
	for pair in CITY_EDGES:
		_graph.add_edge(_cities_grid[pair[0]], _cities_grid[pair[1]])

	# Render tracks
	_renderer = TrackRenderer.new()
	_renderer.setup(_graph)
	_world.add_child(_renderer)

	# Pathfinder
	_pathfinder = TrainPathfinder.new()
	_pathfinder.setup(_graph)

	# Build runtime city states
	_build_city_runtime_states()

	# Treasury from player faction
	var faction: FactionData = _catalog.get_faction_by_id("player_railway_company")
	var starting_capital: int = faction.starting_capital if faction != null else 50000
	_treasury = TreasuryState.new(starting_capital)

	# Arrival handler
	_arrival_handler = StationArrivalHandler.new()
	var city_list: Array[CityRuntimeState] = []
	for city in _city_runtime.values():
		city_list.append(city)
	_arrival_handler.setup(city_list, _treasury, _cargo_catalog)
	add_child(_arrival_handler)

	# Load train data
	_train_data = _catalog.get_train_by_id("freight_engine")
	if _train_data == null:
		push_error("DebugCargoTransaction: freight_engine not found")
		return

	# Spawn train
	var train_scene := preload("res://scenes/trains/train_entity.tscn")
	_train = train_scene.instantiate() as TrainEntity
	_train.setup(_train_data, _pathfinder)
	_world.add_child(_train)

	# Setup cargo
	var train_cargo: TrainCargo = _train.get_train_cargo()
	if train_cargo != null:
		train_cargo.setup_from_train_data(_train_data, _cargo_catalog)

	# Connect arrival handler
	_arrival_handler.connect_train(_train)

	# Reset to Patna
	_reset_train_to("patna")

	_print_banner(starting_capital)

	# Auto-run coal delivery once for headless testing
	_run_delivery("patna", "kolkata", "coal")


func _load_cities() -> void:
	for city_id in ["kolkata", "patna", "dacca", "murshidabad"]:
		var city := _catalog.get_city_by_id(city_id)
		if city == null:
			push_error("DebugCargoTransaction: city '%s' not found" % city_id)
			continue
		_cities_grid[city_id] = city.map_position


func _build_cargo_catalog() -> void:
	for cargo in _catalog.cargos:
		_cargo_catalog[cargo.cargo_id] = cargo


func _build_city_runtime_states() -> void:
	for city_id in ["kolkata", "patna", "dacca", "murshidabad"]:
		var city_data: CityData = _catalog.get_city_by_id(city_id)
		if city_data == null:
			continue
		var runtime := CityRuntimeState.new()
		runtime.setup_from_city_data(city_data, _cargo_catalog)
		_city_runtime[city_id] = runtime


func _print_banner(starting_capital: int) -> void:
	print("")
	print("CARGO TRANSACTION DEBUG")
	print("Loaded city runtime states: %d" % _city_runtime.size())
	print("Treasury before delivery: ₹%d" % starting_capital)

	for city_id in ["patna", "kolkata", "murshidabad", "dacca"]:
		var runtime: CityRuntimeState = _city_runtime[city_id]
		if runtime != null:
			var coal_qty := runtime.get_quantity("coal")
			var grain_qty := runtime.get_quantity("grain")
			print("%s — coal: %d, grain: %d" % [runtime.display_name, coal_qty, grain_qty])

	print("Train capacity: %d tons" % _train_data.capacity_tons)
	print("")
	print("Controls:")
	print("  Space = run Patna -> Kolkata coal delivery")
	print("  R = reset all city stock, treasury, and train position")
	print("  1 = run Patna -> Kolkata coal delivery")
	print("  2 = run Murshidabad -> Dacca grain delivery")
	print("")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				_run_delivery("patna", "kolkata", "coal")
			KEY_R:
				_reset_all()
			KEY_1:
				_run_delivery("patna", "kolkata", "coal")
			KEY_2:
				_run_delivery("murshidabad", "dacca", "grain")


func _run_delivery(from_id: String, to_id: String, cargo_id: String) -> void:
	if _train == null:
		return
	if _train.is_moving():
		print("Train is already moving. Press R to reset.")
		return

	var from_pos: Vector2i = _cities_grid[from_id]
	var to_pos: Vector2i = _cities_grid[to_id]
	var origin_city: CityRuntimeState = _city_runtime[from_id]

	# Reset train to origin
	_train.reset_to(from_pos)

	# Load cargo from origin city
	var train_cargo: TrainCargo = _train.get_train_cargo()
	if train_cargo == null:
		push_error("DebugCargoTransaction: train has no cargo component")
		return

	var origin_stock := origin_city.get_quantity(cargo_id)
	var available_capacity := train_cargo.get_available_capacity_tons()
	var cargo: CargoData = _cargo_catalog.get(cargo_id, null) as CargoData
	var weight := cargo.weight_per_unit if cargo != null else 1.0
	var max_by_capacity := int(floorf(available_capacity / weight))
	var to_load := mini(origin_stock, max_by_capacity)

	if to_load > 0:
		origin_city.remove_cargo(cargo_id, to_load)
		train_cargo.load_cargo(cargo_id, to_load)
		print("Loaded %s: %d" % [cargo_id, to_load])
		print("%s %s after load: %d" % [origin_city.display_name, cargo_id, origin_city.get_quantity(cargo_id)])
		print("Train %s: %d" % [cargo_id, train_cargo.get_quantity(cargo_id)])
	else:
		print("No %s available to load at %s" % [cargo_id, origin_city.display_name])

	# Set route and start
	var ok := _train.set_route(from_pos, to_pos)
	if ok:
		print("Train movement started: %s -> %s" % [_catalog.get_city_by_id(from_id).display_name, _catalog.get_city_by_id(to_id).display_name])
		_train.start_movement()


func _reset_all() -> void:
	# Rebuild city runtime states from static data
	_build_city_runtime_states()

	# Reset treasury
	var faction: FactionData = _catalog.get_faction_by_id("player_railway_company")
	var starting_capital: int = faction.starting_capital if faction != null else 50000
	_treasury = TreasuryState.new(starting_capital)

	# Re-setup arrival handler with new runtime states
	var city_list: Array[CityRuntimeState] = []
	for city in _city_runtime.values():
		city_list.append(city)
	_arrival_handler.setup(city_list, _treasury, _cargo_catalog)

	# Reset train
	_reset_train_to("patna")

	print("")
	print("RESET COMPLETE")
	print("Treasury: ₹%d" % _treasury.balance)
	for city_id in ["patna", "kolkata", "murshidabad", "dacca"]:
		var runtime: CityRuntimeState = _city_runtime[city_id]
		if runtime != null:
			print("%s — coal: %d, grain: %d" % [runtime.display_name, runtime.get_quantity("coal"), runtime.get_quantity("grain")])
	print("")


func _reset_train_to(city_id: String) -> void:
	if _train == null:
		return
	var pos: Vector2i = _cities_grid[city_id]
	_train.reset_to(pos)
	var train_cargo: TrainCargo = _train.get_train_cargo()
	if train_cargo != null:
		train_cargo.inventory.clear()
