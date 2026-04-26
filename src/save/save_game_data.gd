class_name SaveGameData
extends RefCounted


const CURRENT_VERSION: int = 2

var save_version: int = CURRENT_VERSION
var saved_at: String = ""

# Clock
var current_day: int = 1
var current_month: int = 1
var current_year: int = 1857
var clock_is_paused: bool = true
var days_per_real_second: float = 2.0

# Treasury
var treasury_balance: int = 0

# Cities: city_id -> { cargo_id -> quantity }
var city_stocks: Dictionary = {}

# TrackGraph
var track_nodes: Array[Dictionary] = []
var track_edges: Array[Dictionary] = []

# Trains (v2 array — supports multiple trains)
var trains: Array[Dictionary] = []

# Routes (v2 array — supports multiple routes)
var routes: Array[Dictionary] = []

# Legacy v1 fields (kept for backward-compat reading only)
var train_id: String = ""
var train_grid_coord: Dictionary = {"x": 0, "y": 0}
var train_cargo: Dictionary = {}
var route_schedule: Dictionary = {}
var route_stats: Dictionary = {}
var runner_state: String = "IDLE"


func to_json_string() -> String:
	var dict := {
		"save_version": save_version,
		"saved_at": saved_at if not saved_at.is_empty() else Time.get_datetime_string_from_system(),
		"clock": {
			"current_day": current_day,
			"current_month": current_month,
			"current_year": current_year,
			"is_paused": clock_is_paused,
			"days_per_real_second": days_per_real_second,
		},
		"treasury": {
			"balance": treasury_balance,
		},
		"cities": city_stocks,
		"track_graph": {
			"nodes": track_nodes,
			"edges": track_edges,
		},
		"trains": trains,
		"routes": routes,
	}
	return JSON.stringify(dict, "\t")


static func from_json_string(json_str: String) -> SaveGameData:
	var parse_result: Variant = JSON.parse_string(json_str)
	if parse_result == null or typeof(parse_result) != TYPE_DICTIONARY:
		push_error("SaveGameData: invalid JSON")
		return null

	var dict: Dictionary = parse_result
	var data := SaveGameData.new()

	data.save_version = dict.get("save_version", 1) as int
	data.saved_at = dict.get("saved_at", "") as String

	var clock_dict: Dictionary = dict.get("clock", {}) as Dictionary
	data.current_day = clock_dict.get("current_day", 1) as int
	data.current_month = clock_dict.get("current_month", 1) as int
	data.current_year = clock_dict.get("current_year", 1857) as int
	data.clock_is_paused = clock_dict.get("is_paused", true) as bool
	data.days_per_real_second = clock_dict.get("days_per_real_second", 2.0) as float

	var treasury_dict: Dictionary = dict.get("treasury", {}) as Dictionary
	data.treasury_balance = treasury_dict.get("balance", 0) as int

	data.city_stocks = dict.get("cities", {}) as Dictionary

	var track_dict: Dictionary = dict.get("track_graph", {}) as Dictionary
	data.track_nodes = _to_dict_array(track_dict.get("nodes", []))
	data.track_edges = _to_dict_array(track_dict.get("edges", []))

	# v2 arrays
	data.trains = _to_dict_array(dict.get("trains", []))
	data.routes = _to_dict_array(dict.get("routes", []))

	# v1 legacy fallback
	var train_dict: Dictionary = dict.get("train", {}) as Dictionary
	data.train_id = train_dict.get("train_id", "") as String
	data.train_grid_coord = train_dict.get("grid_coord", {"x": 0, "y": 0}) as Dictionary
	data.train_cargo = train_dict.get("cargo", {}) as Dictionary

	var route_dict: Dictionary = dict.get("route", {}) as Dictionary
	data.route_schedule = route_dict.get("schedule", {}) as Dictionary
	data.route_stats = route_dict.get("stats", {}) as Dictionary
	data.runner_state = route_dict.get("runner_state", "IDLE") as String

	return data


static func _to_dict_array(arr: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if typeof(arr) != TYPE_ARRAY:
		return result
	for item in arr as Array:
		if typeof(item) == TYPE_DICTIONARY:
			result.append(item as Dictionary)
	return result
