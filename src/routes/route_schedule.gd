class_name RouteSchedule
extends RefCounted


var route_id: String = ""
var origin_city_id: String = ""
var destination_city_id: String = ""
var cargo_id: String = ""
var loop_enabled: bool = true
var return_empty: bool = true


func validate() -> Array[String]:
	var errors: Array[String] = []

	if route_id.strip_edges().is_empty():
		errors.append("route_id is required")

	if origin_city_id.strip_edges().is_empty():
		errors.append("origin_city_id is required")

	if destination_city_id.strip_edges().is_empty():
		errors.append("destination_city_id is required")

	if origin_city_id == destination_city_id:
		errors.append("origin and destination must be different")

	if cargo_id.strip_edges().is_empty():
		errors.append("cargo_id is required")

	return errors
