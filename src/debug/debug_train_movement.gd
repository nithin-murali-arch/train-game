class_name DebugTrainMovement
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
var _cities: Dictionary = {}  # city_id -> Vector2i


func _ready() -> void:
	_catalog = DataCatalog.new()
	_load_cities()

	# Instance world
	_world = preload("res://scenes/world/world.tscn").instantiate()
	add_child(_world)

	# Build graph with debug edges
	_graph = TrackGraph.new()
	for pair in CITY_EDGES:
		var from_id: String = pair[0]
		var to_id: String = pair[1]
		var from_pos: Vector2i = _cities[from_id]
		var to_pos: Vector2i = _cities[to_id]
		_graph.add_edge(from_pos, to_pos)

	# Render tracks
	_renderer = TrackRenderer.new()
	_renderer.setup(_graph)
	_world.add_child(_renderer)

	# Pathfinder
	_pathfinder = TrainPathfinder.new()
	_pathfinder.setup(_graph)

	# Load train data
	var train_data: TrainData = _catalog.get_train_by_id("freight_engine")
	if train_data == null:
		push_error("DebugTrainMovement: freight_engine not found")
		return

	# Spawn train
	var train_scene := preload("res://scenes/trains/train_entity.tscn")
	_train = train_scene.instantiate() as TrainEntity
	_train.setup(train_data, _pathfinder)
	_world.add_child(_train)

	# Reset to Kolkata
	var kolkata: Vector2i = _cities["kolkata"]
	_train.reset_to(kolkata)

	_print_banner(train_data, kolkata)


func _load_cities() -> void:
	for city_id in ["kolkata", "patna", "dacca", "murshidabad"]:
		var city := _catalog.get_city_by_id(city_id)
		if city == null:
			push_error("DebugTrainMovement: city '%s' not found" % city_id)
			continue
		_cities[city_id] = city.map_position


func _print_banner(train_data: TrainData, kolkata: Vector2i) -> void:
	print("")
	print("TRAIN MOVEMENT DEBUG")
	print("Loaded cities: %d" % _cities.size())
	print("TrackGraph nodes: %d" % _graph.get_node_count())
	print("TrackGraph edges: %d" % _graph.get_edge_count())
	print("Spawned train: %s at %s %s" % [train_data.display_name, _catalog.get_city_by_id("kolkata").display_name, kolkata])
	print("")
	print("Controls:")
	print("  Space = start Kolkata -> Dacca")
	print("  R = reset to Kolkata")
	print("  1 = route Kolkata -> Dacca")
	print("  2 = route Patna -> Murshidabad")
	print("")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				_route_and_start("kolkata", "dacca")
			KEY_R:
				_reset_to_kolkata()
			KEY_1:
				_route_and_start("kolkata", "dacca")
			KEY_2:
				_route_and_start("patna", "murshidabad")


func _route_and_start(from_id: String, to_id: String) -> void:
	if _train == null:
		return
	if _train.is_moving():
		print("Train is already moving. Press R to reset.")
		return

	var from_pos: Vector2i = _cities[from_id]
	var to_pos: Vector2i = _cities[to_id]
	var ok := _train.set_route(from_pos, to_pos)
	if ok:
		_train.start_movement()


func _reset_to_kolkata() -> void:
	if _train == null:
		return
	var kolkata: Vector2i = _cities["kolkata"]
	_train.reset_to(kolkata)
	print("Train reset to Kolkata")
