class_name DebugTrackGraph
extends Node


const CITY_EDGES: Array[Array] = [
	["kolkata", "patna"],
	["kolkata", "murshidabad"],
	["murshidabad", "dacca"],
	["patna", "dacca"],
]

var _catalog: DataCatalog
var _graph: TrackGraph
var _cities: Dictionary = {}  # city_id -> Vector2i
var _pass_count := 0
var _fail_count := 0


func _ready() -> void:
	_catalog = DataCatalog.new()
	_load_cities()
	_build_graph()
	_run_tests()
	_print_summary()


func _load_cities() -> void:
	for city_id in ["kolkata", "patna", "dacca", "murshidabad"]:
		var city := _catalog.get_city_by_id(city_id)
		if city == null:
			push_error("DebugTrackGraph: city '%s' not found" % city_id)
			continue
		_cities[city_id] = city.map_position


func _build_graph() -> void:
	_graph = TrackGraph.new()
	for pair in CITY_EDGES:
		var from_id: String = pair[0]
		var to_id: String = pair[1]
		var from_pos: Vector2i = _cities[from_id]
		var to_pos: Vector2i = _cities[to_id]
		_graph.add_edge(from_pos, to_pos)


func _run_tests() -> void:
	print("TRACKGRAPH DEBUG")
	print("Loaded cities: %d" % _cities.size())
	print("Nodes: %d" % _graph.get_node_count())
	print("Edges: %d" % _graph.get_edge_count())
	print("")

	_test_01_empty_graph()
	_test_02_add_node()
	_test_03_duplicate_node()
	_test_04_edge_auto_adds_nodes()
	_test_05_duplicate_edge()
	_test_06_remove_edge()
	_test_07_remove_node()
	_test_08_path_kolkata_to_dacca()
	_test_09_path_patna_to_murshidabad()
	_test_10_blocked_edge()
	_test_11_missing_node()
	_test_12_self_path()


func _test_01_empty_graph() -> void:
	var g := TrackGraph.new()
	_assert_equal("Test 01 (empty graph)", g.get_node_count(), 0)
	_assert_equal("Test 01 (empty graph)", g.get_edge_count(), 0)


func _test_02_add_node() -> void:
	var g := TrackGraph.new()
	g.add_node(Vector2i(1, 1))
	_assert_equal("Test 02 (add node)", g.get_node_count(), 1)


func _test_03_duplicate_node() -> void:
	var g := TrackGraph.new()
	g.add_node(Vector2i(1, 1))
	var added := g.add_node(Vector2i(1, 1))
	_assert_false("Test 03 (duplicate node)", added)
	_assert_equal("Test 03 (duplicate node)", g.get_node_count(), 1)


func _test_04_edge_auto_adds_nodes() -> void:
	var g := TrackGraph.new()
	g.add_edge(Vector2i(1, 1), Vector2i(2, 2))
	_assert_equal("Test 04 (edge auto-adds)", g.get_node_count(), 2)
	_assert_equal("Test 04 (edge auto-adds)", g.get_edge_count(), 1)


func _test_05_duplicate_edge() -> void:
	var g := TrackGraph.new()
	g.add_edge(Vector2i(1, 1), Vector2i(2, 2))
	var added := g.add_edge(Vector2i(1, 1), Vector2i(2, 2))
	_assert_false("Test 05 (duplicate edge)", added)
	_assert_equal("Test 05 (duplicate edge)", g.get_edge_count(), 1)


func _test_06_remove_edge() -> void:
	var g := TrackGraph.new()
	g.add_edge(Vector2i(1, 1), Vector2i(2, 2))
	g.remove_edge(Vector2i(1, 1), Vector2i(2, 2))
	_assert_equal("Test 06 (remove edge)", g.get_edge_count(), 0)
	_assert_false("Test 06 (remove edge)", g.has_edge(Vector2i(1, 1), Vector2i(2, 2)))
	_assert_false("Test 06 (remove edge)", g.has_edge(Vector2i(2, 2), Vector2i(1, 1)))


func _test_07_remove_node() -> void:
	var g := TrackGraph.new()
	g.add_edge(Vector2i(1, 1), Vector2i(2, 2))
	g.remove_node(Vector2i(1, 1))
	_assert_false("Test 07 (remove node)", g.has_node(Vector2i(1, 1)))
	_assert_false("Test 07 (remove node)", g.has_edge(Vector2i(1, 1), Vector2i(2, 2)))


func _test_08_path_kolkata_to_dacca() -> void:
	var kolkata: Vector2i = _cities["kolkata"]
	var dacca: Vector2i = _cities["dacca"]
	var result := _graph.find_path(kolkata, dacca)
	_assert_true("Test 08 (kolkata -> dacca)", result.success)
	if result.success:
		print("  coords: %d, length: %.1f km, cost: %.1f" % [result.coords.size(), result.total_length_km, result.total_cost])


func _test_09_path_patna_to_murshidabad() -> void:
	var patna: Vector2i = _cities["patna"]
	var murshidabad: Vector2i = _cities["murshidabad"]
	var result := _graph.find_path(patna, murshidabad)
	_assert_true("Test 09 (patna -> murshidabad)", result.success)
	if result.success:
		print("  coords: %d, length: %.1f km, cost: %.1f" % [result.coords.size(), result.total_length_km, result.total_cost])


func _test_10_blocked_edge() -> void:
	# Block Kolkata-Murshidabad; path should reroute via Patna
	var kolkata: Vector2i = _cities["kolkata"]
	var murshidabad: Vector2i = _cities["murshidabad"]
	var dacca: Vector2i = _cities["dacca"]

	var edge := _graph.get_edge(kolkata, murshidabad)
	edge.is_blocked = true

	var result := _graph.find_path(kolkata, dacca)
	_assert_true("Test 10 (blocked edge reroute)", result.success)

	# Verify the path does NOT go through Murshidabad
	var has_murshidabad := false
	for c in result.coords:
		if c == murshidabad:
			has_murshidabad = true
			break
	_assert_false("Test 10 (blocked edge reroute)", has_murshidabad)

	if result.success:
		print("  coords: %d, length: %.1f km, cost: %.1f" % [result.coords.size(), result.total_length_km, result.total_cost])

	# Restore
	edge.is_blocked = false


func _test_11_missing_node() -> void:
	var kolkata: Vector2i = _cities["kolkata"]
	var missing := Vector2i(999, 999)
	var result := _graph.find_path(kolkata, missing)
	_assert_false("Test 11 (missing node)", result.success)
	_assert_equal_str("Test 11 (missing node)", result.error_message, "end node missing")


func _test_12_self_path() -> void:
	var kolkata: Vector2i = _cities["kolkata"]
	var result := _graph.find_path(kolkata, kolkata)
	_assert_true("Test 12 (self path)", result.success)
	_assert_equal("Test 12 (self path)", result.coords.size(), 1)
	_assert_equal("Test 12 (self path)", result.total_length_km, 0.0)


func _print_summary() -> void:
	print("")
	var validation_errors := _graph.validate()
	if validation_errors.is_empty():
		print("Graph validate(): PASS")
	else:
		print("Graph validate(): FAIL")
		for err in validation_errors:
			print("  - %s" % err)
		_fail_count += 1

	print("")
	if _fail_count == 0:
		print("TRACKGRAPH VALIDATION: PASS (%d/%d tests passed)" % [_pass_count, _pass_count + _fail_count])
	else:
		print("TRACKGRAPH VALIDATION: FAIL (%d passed, %d failed)" % [_pass_count, _fail_count])
	get_tree().quit()


# ============================================================================
# Assertion helpers
# ============================================================================

func _assert_true(label: String, condition: bool) -> void:
	if condition:
		print("%s: PASS" % label)
		_pass_count += 1
	else:
		print("%s: FAIL (expected true)" % label)
		_fail_count += 1


func _assert_false(label: String, condition: bool) -> void:
	if not condition:
		print("%s: PASS" % label)
		_pass_count += 1
	else:
		print("%s: FAIL (expected false)" % label)
		_fail_count += 1


func _assert_equal(label: String, actual: Variant, expected: Variant) -> void:
	if actual == expected:
		print("%s: PASS" % label)
		_pass_count += 1
	else:
		print("%s: FAIL (expected %s, got %s)" % [label, expected, actual])
		_fail_count += 1


func _assert_equal_str(label: String, actual: String, expected: String) -> void:
	if actual == expected:
		print("%s: PASS" % label)
		_pass_count += 1
	else:
		print("%s: FAIL (expected '%s', got '%s')" % [label, expected, actual])
		_fail_count += 1
