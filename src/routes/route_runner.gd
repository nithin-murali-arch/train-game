class_name RouteRunner
extends Node


enum State {
	IDLE,
	LOADING_AT_ORIGIN,
	MOVING_TO_DESTINATION,
	UNLOADING_AT_DESTINATION,
	RETURNING_TO_ORIGIN,
	COMPLETE,
	FAILED,
}

signal state_changed(new_state_name: String)
signal trip_completed(stats: RouteProfitStats)
signal route_failed(reason: String)

var _state: int = State.IDLE
var _schedule: RouteSchedule
var _train: TrainEntity
var _train_data: TrainData
var _graph: TrackGraph
var _pathfinder: TrainPathfinder
var _origin_runtime: CityRuntimeState
var _destination_runtime: CityRuntimeState
var _origin_data: CityData
var _destination_data: CityData
var _treasury: TreasuryState
var _cargo_catalog: Dictionary
var _stats: RouteProfitStats

var _origin_grid: Vector2i
var _destination_grid: Vector2i
var _current_trip_loaded: int = 0
var _current_trip_unit_price: float = 0.0
var _current_trip_revenue: int = 0
var _printed_no_cargo_today: bool = false


func setup(
	schedule: RouteSchedule,
	train: TrainEntity,
	train_data: TrainData,
	graph: TrackGraph,
	origin_runtime: CityRuntimeState,
	destination_runtime: CityRuntimeState,
	origin_data: CityData,
	destination_data: CityData,
	treasury: TreasuryState,
	cargo_catalog: Dictionary
) -> void:
	_schedule = schedule
	_train = train
	_train_data = train_data
	_graph = graph
	_origin_runtime = origin_runtime
	_destination_runtime = destination_runtime
	_origin_data = origin_data
	_destination_data = destination_data
	_treasury = treasury
	_cargo_catalog = cargo_catalog

	_origin_grid = origin_runtime.grid_coord
	_destination_grid = destination_runtime.grid_coord

	_stats = RouteProfitStats.new()
	_stats.route_id = schedule.route_id

	_pathfinder = TrainPathfinder.new()
	_pathfinder.setup(_graph)


func start_route() -> void:
	if _state != State.IDLE and _state != State.COMPLETE and _state != State.FAILED:
		return
	_set_state(State.LOADING_AT_ORIGIN)
	_train.reset_to(_origin_grid)
	print("Route started: %s -> %s, cargo=%s" % [_origin_data.display_name, _destination_data.display_name, _schedule.cargo_id])


func stop_route() -> void:
	_set_state(State.IDLE)
	if _train.is_moving():
		_train._movement.stop()


func reset_route() -> void:
	stop_route()
	_stats.reset()
	_current_trip_loaded = 0
	_current_trip_unit_price = 0.0
	_current_trip_revenue = 0
	_printed_no_cargo_today = false
	_train.reset_to(_origin_grid)
	print("Route reset")


func get_stats() -> RouteProfitStats:
	return _stats


func get_state_name() -> String:
	match _state:
		State.IDLE: return "IDLE"
		State.LOADING_AT_ORIGIN: return "LOADING_AT_ORIGIN"
		State.MOVING_TO_DESTINATION: return "MOVING_TO_DESTINATION"
		State.UNLOADING_AT_DESTINATION: return "UNLOADING_AT_DESTINATION"
		State.RETURNING_TO_ORIGIN: return "RETURNING_TO_ORIGIN"
		State.COMPLETE: return "COMPLETE"
		State.FAILED: return "FAILED"
		_: return "UNKNOWN"


func on_day_passed() -> void:
	if _state == State.LOADING_AT_ORIGIN:
		_printed_no_cargo_today = false
		_attempt_load()


func _process(_delta: float) -> void:
	match _state:
		State.LOADING_AT_ORIGIN:
			_process_loading()
		State.MOVING_TO_DESTINATION:
			_process_moving_to_destination()
		State.UNLOADING_AT_DESTINATION:
			_process_unloading()
		State.RETURNING_TO_ORIGIN:
			_process_returning()


func _process_loading() -> void:
	_attempt_load()


func _attempt_load() -> void:
	var train_cargo: TrainCargo = _train.get_train_cargo()
	if train_cargo == null:
		_print_failure("train has no cargo component")
		return

	var origin_stock := _origin_runtime.get_quantity(_schedule.cargo_id)
	if origin_stock <= 0:
		if not _printed_no_cargo_today:
			print("No %s available at %s — waiting for next day" % [_schedule.cargo_id, _origin_data.display_name])
			_printed_no_cargo_today = true
		return

	train_cargo.inventory.clear()
	var available_capacity := train_cargo.get_available_capacity_tons()
	var cargo: CargoData = _cargo_catalog.get(_schedule.cargo_id, null) as CargoData
	var weight := cargo.weight_per_unit if cargo != null else 1.0
	var max_by_capacity := int(floorf(available_capacity / weight))
	var to_load := mini(origin_stock, max_by_capacity)

	if to_load > 0:
		_origin_runtime.remove_cargo(_schedule.cargo_id, to_load)
		train_cargo.load_cargo(_schedule.cargo_id, to_load)
		_current_trip_loaded = to_load
		print("Loaded %s: %d at %s" % [_schedule.cargo_id, to_load, _origin_data.display_name])
		_set_state(State.MOVING_TO_DESTINATION)
		_start_movement(_origin_grid, _destination_grid)


func _start_movement(from: Vector2i, to: Vector2i) -> void:
	var ok := _train.set_route(from, to)
	if not ok:
		_print_failure("no path from %s to %s" % [from, to])
		return

	# Ensure no duplicate signal connection
	if _train._movement.destination_arrived.is_connected(_on_destination_arrived):
		_train._movement.destination_arrived.disconnect(_on_destination_arrived)
	_train._movement.destination_arrived.connect(_on_destination_arrived, CONNECT_ONE_SHOT)
	_train.start_movement()


func _process_moving_to_destination() -> void:
	# Movement is handled by TrainMovement._process
	# We just wait for the arrival signal
	pass


func _on_destination_arrived(coord: Vector2i) -> void:
	match _state:
		State.MOVING_TO_DESTINATION:
			_set_state(State.UNLOADING_AT_DESTINATION)
		State.RETURNING_TO_ORIGIN:
			if _schedule.loop_enabled:
				_set_state(State.LOADING_AT_ORIGIN)
				_printed_no_cargo_today = false
			else:
				_set_state(State.COMPLETE)
				print("Route complete")


func _process_unloading() -> void:
	var train_cargo: TrainCargo = _train.get_train_cargo()
	if train_cargo == null:
		_print_failure("train has no cargo component")
		return

	var delivered := train_cargo.get_quantity(_schedule.cargo_id)

	# 1. Quote dynamic price BEFORE unloading
	var unit_price := MarketPricing.get_sell_price(_schedule.cargo_id, _destination_runtime, _destination_data, _cargo_catalog)
	_current_trip_unit_price = unit_price

	print("%s %s dynamic price before delivery: ₹%.0f" % [_destination_data.display_name, _schedule.cargo_id, unit_price])

	# 2. Unload cargo into destination inventory
	var unloaded := train_cargo.unload_all_to(_destination_runtime.inventory)

	# 3. Sell delivered quantity using quoted price
	if unloaded > 0:
		_current_trip_revenue = int(roundf(float(unloaded) * unit_price))
		_treasury.add(_current_trip_revenue)
		print("Sold %s: %d × ₹%.0f = ₹%d" % [_schedule.cargo_id, unloaded, unit_price, _current_trip_revenue])

	# 4. Deduct maintenance/operating cost
	var operating_cost := _train_data.maintenance_per_day
	if operating_cost > 0:
		if _treasury.can_afford(operating_cost):
			_treasury.spend(operating_cost)
			print("Maintenance cost: ₹%d" % operating_cost)
		else:
			print("INSUFFICIENT FUNDS: Cannot pay maintenance ₹%d. Treasury: ₹%d" % [operating_cost, _treasury.balance])
			_print_failure("insufficient funds for maintenance")
			return

	# 5. Record trip stats
	_stats.record_trip(unloaded, _current_trip_revenue, operating_cost)
	trip_completed.emit(_stats)
	print("Trip profit: ₹%d" % _stats.last_trip_profit)
	print("Treasury: ₹%d" % _treasury.balance)

	# 6. Decide next state
	if _schedule.return_empty:
		_set_state(State.RETURNING_TO_ORIGIN)
		_train._movement.destination_arrived.connect(_on_destination_arrived, CONNECT_ONE_SHOT)
		_train.set_route(_destination_grid, _origin_grid)
		_train.start_movement()
		print("Returning to %s" % _origin_data.display_name)
	elif _schedule.loop_enabled:
		_set_state(State.LOADING_AT_ORIGIN)
		_printed_no_cargo_today = false
		_train.reset_to(_origin_grid)
	else:
		_set_state(State.COMPLETE)
		print("Route complete")


func _process_returning() -> void:
	# Movement handled by TrainMovement
	pass


func set_state_by_name(state_name: String) -> void:
	match state_name:
		"IDLE": _set_state(State.IDLE)
		"LOADING_AT_ORIGIN": _set_state(State.LOADING_AT_ORIGIN)
		"MOVING_TO_DESTINATION": _set_state(State.MOVING_TO_DESTINATION)
		"UNLOADING_AT_DESTINATION": _set_state(State.UNLOADING_AT_DESTINATION)
		"RETURNING_TO_ORIGIN": _set_state(State.RETURNING_TO_ORIGIN)
		"COMPLETE": _set_state(State.COMPLETE)
		"FAILED": _set_state(State.FAILED)


func inject_runtime_refs(origin_runtime: CityRuntimeState, destination_runtime: CityRuntimeState, treasury_ref: TreasuryState) -> void:
	_origin_runtime = origin_runtime
	_destination_runtime = destination_runtime
	_treasury = treasury_ref
	_origin_grid = origin_runtime.grid_coord if origin_runtime != null else Vector2i.ZERO
	_destination_grid = destination_runtime.grid_coord if destination_runtime != null else Vector2i.ZERO


func _set_state(new_state: int) -> void:
	if _state == new_state:
		return
	_state = new_state
	state_changed.emit(get_state_name())


func _print_failure(reason: String) -> void:
	_set_state(State.FAILED)
	route_failed.emit(reason)
	print("Route FAILED: %s" % reason)
