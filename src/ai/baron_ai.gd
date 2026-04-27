class_name BaronAI
extends Node


enum State {
	ANALYZE,
	BUILD_TRACK,
	BUY_TRAIN,
	CREATE_ROUTE,
	OPERATE,
	PAUSE_ON_LOSS,
}

var _state: int = State.ANALYZE

var _graph: TrackGraph = null
var _faction_manager: FactionManager = null
var _city_runtime: Dictionary = {}
var _city_data_by_id: Dictionary = {}
var _cargo_catalog: Dictionary = {}
var _cities_grid: Dictionary = {}
var _world: Node2D = null
var _catalog: DataCatalog = null
var _get_maintenance_discount_cb: Callable = Callable()

var _ai_train: TrainEntity = null
var _ai_runner: RouteRunner = null

var _consecutive_unprofitable_trips: int = 0
var _trip_count: int = 0

const TRACK_COST_PER_KM: float = 500.0


func setup(
	graph: TrackGraph,
	faction_manager: FactionManager,
	city_runtime: Dictionary,
	city_data_by_id: Dictionary,
	cargo_catalog: Dictionary,
	cities_grid: Dictionary,
	world: Node2D,
	catalog: DataCatalog,
	get_maintenance_discount_cb: Callable = Callable()
) -> void:
	_graph = graph
	_faction_manager = faction_manager
	_city_runtime = city_runtime
	_city_data_by_id = city_data_by_id
	_cargo_catalog = cargo_catalog
	_cities_grid = cities_grid
	_world = world
	_catalog = catalog
	_get_maintenance_discount_cb = get_maintenance_discount_cb


func tick(day: int, month: int, year: int) -> void:
	match _state:
		State.ANALYZE:
			_tick_analyze()
		State.BUILD_TRACK:
			_tick_build_track()
		State.BUY_TRAIN:
			_tick_buy_train()
		State.CREATE_ROUTE:
			_tick_create_route()
		State.OPERATE:
			_tick_operate()
		State.PAUSE_ON_LOSS:
			pass


func get_state_name() -> String:
	match _state:
		State.ANALYZE: return "ANALYZE"
		State.BUILD_TRACK: return "BUILD_TRACK"
		State.BUY_TRAIN: return "BUY_TRAIN"
		State.CREATE_ROUTE: return "CREATE_ROUTE"
		State.OPERATE: return "OPERATE"
		State.PAUSE_ON_LOSS: return "PAUSE_ON_LOSS"
		_: return "UNKNOWN"


func to_dict() -> Dictionary:
	return {
		"state": get_state_name(),
		"trip_count": _trip_count,
		"consecutive_unprofitable_trips": _consecutive_unprofitable_trips,
	}


func from_dict(dict: Dictionary) -> void:
	var state_name: String = dict.get("state", "ANALYZE") as String
	match state_name:
		"ANALYZE": _state = State.ANALYZE
		"BUILD_TRACK": _state = State.BUILD_TRACK
		"BUY_TRAIN": _state = State.BUY_TRAIN
		"CREATE_ROUTE": _state = State.CREATE_ROUTE
		"OPERATE": _state = State.OPERATE
		"PAUSE_ON_LOSS": _state = State.PAUSE_ON_LOSS
	_trip_count = dict.get("trip_count", 0) as int
	_consecutive_unprofitable_trips = dict.get("consecutive_unprofitable_trips", 0) as int


# ------------------------------------------------------------------------------
# State ticks
# ------------------------------------------------------------------------------

func _tick_analyze() -> void:
	# Hardcoded first route for Sprint 15: Patna -> Kolkata, coal
	var origin_id := "patna"
	var dest_id := "kolkata"

	if not _cities_grid.has(origin_id) or not _cities_grid.has(dest_id):
		return

	var origin_grid: Vector2i = _cities_grid[origin_id]
	var dest_grid: Vector2i = _cities_grid[dest_id]

	# Check if track exists
	if _graph != null and _graph.has_node(origin_grid) and _graph.has_node(dest_grid):
		var path_result: TrackPathResult = _graph.find_path(origin_grid, dest_grid, FactionManager.FACTION_BRITISH)
		if path_result.success:
			_state = State.BUY_TRAIN
			return

	_state = State.BUILD_TRACK


func _tick_build_track() -> void:
	var origin_id := "patna"
	var dest_id := "kolkata"
	var origin_grid: Vector2i = _cities_grid[origin_id]
	var dest_grid: Vector2i = _cities_grid[dest_id]

	var length_km := origin_grid.distance_to(dest_grid)
	var cost := int(roundf(length_km * TRACK_COST_PER_KM))

	if not _faction_manager.can_afford(FactionManager.FACTION_BRITISH, cost):
		print("BaronAI: cannot afford track build cost ₹%d" % cost)
		_state = State.PAUSE_ON_LOSS
		return

	if _graph != null:
		_graph.add_edge(origin_grid, dest_grid, FactionManager.FACTION_BRITISH)
		_faction_manager.spend_money(FactionManager.FACTION_BRITISH, cost)
		print("BaronAI: built track %s -> %s for ₹%d" % [origin_id, dest_id, cost])

	_state = State.BUY_TRAIN


func _tick_buy_train() -> void:
	var t_data: TrainData = _catalog.get_train_by_id("freight_engine")
	if t_data == null:
		print("BaronAI: freight_engine data not found")
		_state = State.PAUSE_ON_LOSS
		return

	if not _faction_manager.can_afford(FactionManager.FACTION_BRITISH, t_data.cost):
		print("BaronAI: cannot afford train cost ₹%d" % t_data.cost)
		_state = State.PAUSE_ON_LOSS
		return

	var pf := TrainPathfinder.new()
	pf.setup(_graph)

	var train_scene := preload("res://scenes/trains/train_entity.tscn")
	var t := train_scene.instantiate() as TrainEntity
	t.setup(t_data, pf)
	_world.add_child(t)

	var train_cargo: TrainCargo = t.get_train_cargo()
	if train_cargo != null:
		train_cargo.setup_from_train_data(t_data, _cargo_catalog)

	t.reset_to(_cities_grid["patna"])
	t.instance_id = "ai_train_001"

	_faction_manager.spend_money(FactionManager.FACTION_BRITISH, t_data.cost)
	_ai_train = t

	# Register with parent RouteToyPlayable
	var parent_rt := get_parent() as RouteToyPlayable
	if parent_rt != null:
		parent_rt.ai_trains.append(t)

	print("BaronAI: purchased freight_engine (ai_train_001) at Patna for ₹%d" % t_data.cost)
	_state = State.CREATE_ROUTE


func _tick_create_route() -> void:
	if _ai_train == null:
		_state = State.PAUSE_ON_LOSS
		return

	var origin_id := "patna"
	var dest_id := "kolkata"
	var cargo_id := "coal"

	var t_data: TrainData = _ai_train.train_data

	var new_schedule := RouteSchedule.new()
	new_schedule.instance_id = "ai_route_001"
	new_schedule.assigned_train_instance_id = _ai_train.instance_id
	new_schedule.route_id = "%s_to_%s_%s" % [origin_id, dest_id, cargo_id]
	new_schedule.origin_city_id = origin_id
	new_schedule.destination_city_id = dest_id
	new_schedule.cargo_id = cargo_id
	new_schedule.loop_enabled = true
	new_schedule.return_empty = true

	var parent_rt := get_parent() as RouteToyPlayable
	if parent_rt == null:
		print("BaronAI: no parent RouteToyPlayable")
		_state = State.PAUSE_ON_LOSS
		return

	_ai_runner = parent_rt.create_ai_route(new_schedule, _ai_train, t_data)
	if _ai_runner == null:
		print("BaronAI: failed to create route")
		_state = State.PAUSE_ON_LOSS
		return

	_ai_runner.trip_completed.connect(_on_ai_trip_completed)
	_ai_runner.start_route()

	print("BaronAI: created route %s -> %s (%s)" % [origin_id, dest_id, cargo_id])
	_state = State.OPERATE


func _tick_operate() -> void:
	if _ai_runner == null:
		_state = State.PAUSE_ON_LOSS
		return

	var state_name := _ai_runner.get_state_name()
	if state_name == "IDLE":
		_ai_runner.start_route()

	var british_balance := _faction_manager.get_balance(FactionManager.FACTION_BRITISH)
	if british_balance < 10000:
		print("BaronAI: treasury low (₹%d), pausing" % british_balance)
		_state = State.PAUSE_ON_LOSS
		return

	if _consecutive_unprofitable_trips >= 10:
		print("BaronAI: 10 unprofitable trips, pausing")
		_state = State.PAUSE_ON_LOSS


func _on_ai_trip_completed(_stats: RouteProfitStats) -> void:
	_trip_count += 1
	if _stats != null and _stats.last_trip_profit < 0:
		_consecutive_unprofitable_trips += 1
	else:
		_consecutive_unprofitable_trips = 0
