class_name EventRuntimeState
extends RefCounted


enum Status {
	WARNING,
	ACTIVE,
	RESOLVED,
	EXPIRED,
}

var event_id: String = ""
var display_name: String = ""
var description: String = ""
var event_type: String = ""  # monsoon_flood, labor_strike, port_boom, track_inspection
var status: int = Status.WARNING

var affected_city_id: String = ""
var affected_edge_from: Vector2i = Vector2i.ZERO
var affected_edge_to: Vector2i = Vector2i.ZERO
var affected_cargo_id: String = ""

var warning_absolute_day: int = 0
var start_absolute_day: int = 0
var end_absolute_day: int = 0

var severity: int = 1
var effect_data: Dictionary = {}
var was_warned: bool = false
var fine_amount: int = 0


func get_status_name() -> String:
	match status:
		Status.WARNING: return "Warning"
		Status.ACTIVE: return "Active"
		Status.RESOLVED: return "Resolved"
		Status.EXPIRED: return "Expired"
		_: return "Unknown"


func is_warning(day: int) -> bool:
	return status == Status.WARNING and day >= warning_absolute_day and day < start_absolute_day


func is_active(day: int) -> bool:
	return status == Status.ACTIVE and day >= start_absolute_day and day <= end_absolute_day


func is_expired(day: int) -> bool:
	return status == Status.EXPIRED or day > end_absolute_day


func to_dict() -> Dictionary:
	return {
		"event_id": event_id,
		"display_name": display_name,
		"description": description,
		"event_type": event_type,
		"status": get_status_name(),
		"affected_city_id": affected_city_id,
		"affected_edge_from": {"x": affected_edge_from.x, "y": affected_edge_from.y},
		"affected_edge_to": {"x": affected_edge_to.x, "y": affected_edge_to.y},
		"affected_cargo_id": affected_cargo_id,
		"warning_absolute_day": warning_absolute_day,
		"start_absolute_day": start_absolute_day,
		"end_absolute_day": end_absolute_day,
		"severity": severity,
		"effect_data": effect_data,
		"was_warned": was_warned,
		"fine_amount": fine_amount,
	}


static func from_dict(dict: Dictionary) -> EventRuntimeState:
	var s := EventRuntimeState.new()
	s.event_id = dict.get("event_id", "") as String
	s.display_name = dict.get("display_name", "") as String
	s.description = dict.get("description", "") as String
	s.event_type = dict.get("event_type", "") as String
	s.affected_city_id = dict.get("affected_city_id", "") as String

	var from_dict_data: Dictionary = dict.get("affected_edge_from", {}) as Dictionary
	s.affected_edge_from = Vector2i(from_dict_data.get("x", 0) as int, from_dict_data.get("y", 0) as int)

	var to_dict_data: Dictionary = dict.get("affected_edge_to", {}) as Dictionary
	s.affected_edge_to = Vector2i(to_dict_data.get("x", 0) as int, to_dict_data.get("y", 0) as int)

	s.affected_cargo_id = dict.get("affected_cargo_id", "") as String
	s.warning_absolute_day = dict.get("warning_absolute_day", 0) as int
	s.start_absolute_day = dict.get("start_absolute_day", 0) as int
	s.end_absolute_day = dict.get("end_absolute_day", 0) as int
	s.severity = dict.get("severity", 1) as int
	s.effect_data = dict.get("effect_data", {}) as Dictionary
	s.was_warned = dict.get("was_warned", false) as bool
	s.fine_amount = dict.get("fine_amount", 0) as int

	var status_str: String = dict.get("status", "Warning") as String
	s.status = _status_from_name(status_str)
	return s


static func _status_from_name(name: String) -> int:
	match name:
		"Warning": return Status.WARNING
		"Active": return Status.ACTIVE
		"Resolved": return Status.RESOLVED
		"Expired": return Status.EXPIRED
		_: return Status.WARNING
