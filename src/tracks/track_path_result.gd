class_name TrackPathResult
extends RefCounted


var success: bool = false
var coords: Array[Vector2i] = []
var total_length_km: float = 0.0
var total_cost: float = 0.0
var error_message: String = ""


func _to_string() -> String:
	if success:
		return "PathResult(success, %d coords, %.1f km, %.1f cost)" % [coords.size(), total_length_km, total_cost]
	else:
		return "PathResult(failed: %s)" % error_message
