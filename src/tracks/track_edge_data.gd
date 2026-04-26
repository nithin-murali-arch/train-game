class_name TrackEdgeData
extends RefCounted


var from_coord: Vector2i
var to_coord: Vector2i
var owner_faction_id: String = "player_railway_company"
var length_km: float = 0.0
var condition: float = 1.0
var toll_per_km: float = 0.0
var access_mode: String = "private"  # private | open | restricted
var is_blocked: bool = false


func validate() -> Array[String]:
	var errors: Array[String] = []

	if from_coord == to_coord:
		errors.append("from_coord and to_coord must be different")

	if owner_faction_id.strip_edges().is_empty():
		errors.append("owner_faction_id is required")

	if length_km <= 0.0:
		errors.append("length_km must be > 0")

	if condition < 0.0 or condition > 1.0:
		errors.append("condition must be in [0.0, 1.0]")

	if toll_per_km < 0.0:
		errors.append("toll_per_km must be >= 0")

	var valid_modes := ["private", "open", "restricted"]
	if not valid_modes.has(access_mode):
		errors.append("access_mode must be private, open, or restricted")

	return errors
