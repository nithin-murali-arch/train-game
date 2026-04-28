class_name EventManager
extends Node


signal event_warning_issued(event_state: EventRuntimeState)
signal event_started(event_state: EventRuntimeState)
signal event_resolved(event_state: EventRuntimeState)
signal event_expired(event_state: EventRuntimeState)

const MAX_RESOLVED_HISTORY := 20

var _warning_events: Array[EventRuntimeState] = []
var _active_events: Array[EventRuntimeState] = []
var _resolved_events: Array[EventRuntimeState] = []

var _city_data_by_id: Dictionary = {}
var _graph: TrackGraph = null
var _city_runtime: Dictionary = {}
var _treasury: TreasuryState = null
var _event_counter: int = 1
var _rng: RandomNumberGenerator = null


func setup(city_data_by_id: Dictionary, graph: TrackGraph, city_runtime: Dictionary = {}, treasury: TreasuryState = null) -> void:
	_city_data_by_id = city_data_by_id
	_graph = graph
	_city_runtime = city_runtime
	_treasury = treasury
	_rng = RandomNumberGenerator.new()
	_rng.seed = 12345


func set_rng_seed(seed_value: int) -> void:
	if _rng == null:
		_rng = RandomNumberGenerator.new()
	_rng.seed = seed_value


func tick(current_day: int, current_month: int, current_year: int) -> void:
	var current_abs: int = _to_absolute_day(current_day, current_month, current_year)
	_advance_warning_events(current_abs)
	_advance_active_events(current_abs)
	_apply_active_effects(current_abs)


func generate_event(event_type: String, params: Dictionary = {}) -> EventRuntimeState:
	var event := EventRuntimeState.new()
	event.event_id = "event_%03d" % _event_counter
	_event_counter += 1
	event.event_type = event_type

	var current_abs: int = params.get("current_absolute_day", 0) as int
	var warning_days: int = params.get("warning_days", 3) as int
	var duration_days: int = params.get("duration_days", 7) as int
	event.severity = params.get("severity", 1) as int

	event.affected_city_id = params.get("affected_city_id", "") as String
	event.affected_cargo_id = params.get("affected_cargo_id", "") as String

	var from_x: int = params.get("affected_edge_from_x", 0) as int
	var from_y: int = params.get("affected_edge_from_y", 0) as int
	var to_x: int = params.get("affected_edge_to_x", 0) as int
	var to_y: int = params.get("affected_edge_to_y", 0) as int
	event.affected_edge_from = Vector2i(from_x, from_y)
	event.affected_edge_to = Vector2i(to_x, to_y)

	event.effect_data = params.get("effect_data", {}) as Dictionary
	event.fine_amount = params.get("fine_amount", 0) as int

	match event_type:
		"monsoon_flood":
			event.display_name = params.get("display_name", "Monsoon Flood") as String
			event.description = params.get("description", "Heavy rains have flooded the tracks.") as String
			warning_days = params.get("warning_days", 5) as int
			duration_days = params.get("duration_days", 10) as int
			if not event.effect_data.has("block_duration"):
				event.effect_data["block_duration"] = 10
		"labor_strike":
			event.display_name = params.get("display_name", "Labor Strike") as String
			event.description = params.get("description", "Workers have halted operations.") as String
			warning_days = params.get("warning_days", 3) as int
			duration_days = params.get("duration_days", 7) as int
			if not event.effect_data.has("loading_penalty"):
				event.effect_data["loading_penalty"] = 0.5
		"port_boom":
			event.display_name = params.get("display_name", "Port Boom") as String
			event.description = params.get("description", "Trade volume has surged at the port.") as String
			warning_days = 0
			duration_days = params.get("duration_days", 15) as int
			if not event.effect_data.has("demand_multiplier"):
				event.effect_data["demand_multiplier"] = 2.0
			if not event.effect_data.has("production_multiplier"):
				event.effect_data["production_multiplier"] = 2.0
		"track_inspection":
			event.display_name = params.get("display_name", "Track Inspection") as String
			event.description = params.get("description", "Officials are inspecting track conditions.") as String
			warning_days = params.get("warning_days", 7) as int
			duration_days = params.get("duration_days", 1) as int
			if not event.effect_data.has("condition_threshold"):
				event.effect_data["condition_threshold"] = 0.5
			if not event.effect_data.has("fine_multiplier"):
				event.effect_data["fine_multiplier"] = 0.5
		_:
			event.display_name = params.get("display_name", "Unknown Event") as String
			event.description = params.get("description", "") as String

	event.warning_absolute_day = current_abs
	event.start_absolute_day = current_abs + warning_days
	event.end_absolute_day = event.start_absolute_day + duration_days

	_warning_events.append(event)
	return event


func resolve_event(event_id: String) -> bool:
	var event := _find_in_active(event_id)
	if event == null:
		event = _find_in_warning(event_id)
	if event == null:
		return false

	if event.status == EventRuntimeState.Status.ACTIVE:
		_active_events.erase(event)
	else:
		_warning_events.erase(event)

	event.status = EventRuntimeState.Status.RESOLVED
	_add_to_resolved(event)
	_revert_event_effects(event)
	event_resolved.emit(event)
	return true


func get_warning_events() -> Array[EventRuntimeState]:
	return _warning_events.duplicate()


func get_active_events() -> Array[EventRuntimeState]:
	return _active_events.duplicate()


func get_recent_resolved() -> Array[EventRuntimeState]:
	return _resolved_events.duplicate()


func to_dict() -> Dictionary:
	return {
		"event_counter": _event_counter,
		"rng_seed": _rng.seed if _rng != null else 12345,
		"warning_events": _events_to_dict_array(_warning_events),
		"active_events": _events_to_dict_array(_active_events),
		"resolved_events": _events_to_dict_array(_resolved_events),
	}


static func from_dict(dict: Dictionary) -> EventManager:
	var em := EventManager.new()
	em.restore_from_dict(dict)
	return em


func restore_from_dict(dict: Dictionary) -> void:
	_event_counter = dict.get("event_counter", 1) as int
	var seed_value: int = dict.get("rng_seed", 12345) as int
	if _rng == null:
		_rng = RandomNumberGenerator.new()
	_rng.seed = seed_value
	_warning_events = _dict_array_to_events(dict.get("warning_events", []))
	_active_events = _dict_array_to_events(dict.get("active_events", []))
	_resolved_events = _dict_array_to_events(dict.get("resolved_events", []))


func _advance_warning_events(current_abs: int) -> void:
	var to_activate: Array[EventRuntimeState] = []
	for event in _warning_events:
		if not event.was_warned and current_abs >= event.warning_absolute_day:
			event.was_warned = true
			event_warning_issued.emit(event)
		if current_abs >= event.start_absolute_day:
			event.status = EventRuntimeState.Status.ACTIVE
			to_activate.append(event)

	for event in to_activate:
		_warning_events.erase(event)
		_active_events.append(event)
		event_started.emit(event)


func _advance_active_events(current_abs: int) -> void:
	var to_expire: Array[EventRuntimeState] = []
	for event in _active_events:
		if current_abs > event.end_absolute_day:
			event.status = EventRuntimeState.Status.EXPIRED
			to_expire.append(event)

	for event in to_expire:
		_active_events.erase(event)
		_add_to_resolved(event)
		_revert_event_effects(event)
		event_expired.emit(event)


func _apply_active_effects(current_abs: int) -> void:
	for event in _active_events:
		match event.event_type:
			"monsoon_flood":
				_apply_monsoon_flood(event)
			"labor_strike":
				_apply_labor_strike(event)
			"port_boom":
				_apply_port_boom(event)
			"track_inspection":
				_apply_track_inspection(event, current_abs)


func _apply_monsoon_flood(event: EventRuntimeState) -> void:
	if event.affected_edge_from == event.affected_edge_to:
		return
	var edge := _graph.get_edge(event.affected_edge_from, event.affected_edge_to) if _graph != null else null
	if edge == null:
		return
	edge.is_blocked = true
	var damage: float = event.effect_data.get("daily_condition_loss", 0.05) as float
	edge.condition = maxf(edge.condition - damage, 0.0)


func _apply_labor_strike(event: EventRuntimeState) -> void:
	if event.affected_city_id.is_empty():
		return
	var runtime: CityRuntimeState = _city_runtime.get(event.affected_city_id, null) as CityRuntimeState
	if runtime == null:
		return
	runtime.is_striking = true


func _apply_port_boom(event: EventRuntimeState) -> void:
	if event.affected_city_id.is_empty() or event.affected_cargo_id.is_empty():
		return
	var runtime: CityRuntimeState = _city_runtime.get(event.affected_city_id, null) as CityRuntimeState
	if runtime == null:
		return
	var demand_mult: float = event.effect_data.get("demand_multiplier", 2.0) as float
	var prod_mult: float = event.effect_data.get("production_multiplier", 2.0) as float
	runtime.port_boom_multipliers[event.affected_cargo_id] = {
		"demand_multiplier": demand_mult,
		"production_multiplier": prod_mult,
	}


func _apply_track_inspection(event: EventRuntimeState, current_abs: int) -> void:
	var inspected_day: int = event.effect_data.get("inspected_day", -1) as int
	if inspected_day >= 0:
		return
	if _graph == null or _treasury == null:
		return
	event.effect_data["inspected_day"] = current_abs
	var threshold: float = event.effect_data.get("condition_threshold", 0.5) as float
	var fine_mult: float = event.effect_data.get("fine_multiplier", 0.5) as float
	var total_fine: int = 0
	var repair := TrackRepair.new()
	for edge in _graph.get_all_edges():
		if edge.condition < threshold:
			var repair_cost: int = repair.calculate_repair_cost(edge)
			var fine: int = int(roundf(repair_cost * fine_mult))
			if fine > 0:
				total_fine += fine
	if total_fine > 0:
		event.fine_amount = total_fine
		_treasury.spend(total_fine)
		print("Track inspection fine: ₹%d" % total_fine)


func _revert_event_effects(event: EventRuntimeState) -> void:
	match event.event_type:
		"monsoon_flood":
			if event.affected_edge_from == event.affected_edge_to:
				return
			var edge := _graph.get_edge(event.affected_edge_from, event.affected_edge_to) if _graph != null else null
			if edge == null:
				return
			edge.is_blocked = false
		"labor_strike":
			if event.affected_city_id.is_empty():
				return
			var runtime: CityRuntimeState = _city_runtime.get(event.affected_city_id, null) as CityRuntimeState
			if runtime == null:
				return
			runtime.is_striking = false
		"port_boom":
			if event.affected_city_id.is_empty() or event.affected_cargo_id.is_empty():
				return
			var runtime: CityRuntimeState = _city_runtime.get(event.affected_city_id, null) as CityRuntimeState
			if runtime == null:
				return
			runtime.port_boom_multipliers.erase(event.affected_cargo_id)


func apply_effects(day: int, month: int, year: int) -> void:
	var current_abs: int = _to_absolute_day(day, month, year)
	_apply_active_effects(current_abs)


func remove_effects() -> void:
	for event in _active_events:
		_revert_event_effects(event)


func _add_to_resolved(event: EventRuntimeState) -> void:
	_resolved_events.append(event)
	while _resolved_events.size() > MAX_RESOLVED_HISTORY:
		_resolved_events.remove_at(0)


func _find_in_active(event_id: String) -> EventRuntimeState:
	for event in _active_events:
		if event.event_id == event_id:
			return event
	return null


func _find_in_warning(event_id: String) -> EventRuntimeState:
	for event in _warning_events:
		if event.event_id == event_id:
			return event
	return null


static func _events_to_dict_array(events: Array[EventRuntimeState]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event in events:
		result.append(event.to_dict())
	return result


static func _to_absolute_day(day: int, month: int, year: int) -> int:
	return ((year - 1857) * 360) + ((month - 1) * 30) + day


static func _dict_array_to_events(arr: Variant) -> Array[EventRuntimeState]:
	var result: Array[EventRuntimeState] = []
	if typeof(arr) != TYPE_ARRAY:
		return result
	for item in arr as Array:
		if typeof(item) == TYPE_DICTIONARY:
			result.append(EventRuntimeState.from_dict(item as Dictionary))
	return result
