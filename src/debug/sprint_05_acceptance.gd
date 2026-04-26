extends Node

## Sprint 05 Acceptance Verification
## Tests train entity, movement, and pathfinding without human input.

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
var _cities: Dictionary = {}

var _results: Dictionary = {}
var _issues: Array[String] = []
var _arrival_count := 0
var _self_arrived := false


func _ready() -> void:
	print("========================================")
	print("SPRINT 05 ACCEPTANCE VERIFICATION")
	print("========================================")
	print("")

	await _setup_scene()

	_test_01_spawn_at_city()
	_test_02_path_kolkata_to_dacca()
	await _test_03_train_moves_along_path()
	_test_04_multi_segment_path()
	await _test_05_train_stops_at_destination()
	_test_06_missing_path_fails_gracefully()
	_test_07_empty_path_fails()
	await _test_08_self_path_immediate_arrival()
	await _test_09_train_rotates_to_face_direction()
	_test_10_no_scope_creep()

	_print_report()


func _setup_scene() -> void:
	_catalog = DataCatalog.new()
	for city_id in ["kolkata", "patna", "dacca", "murshidabad"]:
		var city := _catalog.get_city_by_id(city_id)
		if city != null:
			_cities[city_id] = city.map_position

	_world = preload("res://scenes/world/world.tscn").instantiate()
	add_child(_world)

	_graph = TrackGraph.new()
	for pair in CITY_EDGES:
		_graph.add_edge(_cities[pair[0]], _cities[pair[1]])

	_renderer = TrackRenderer.new()
	_renderer.setup(_graph)
	_world.add_child(_renderer)

	_pathfinder = TrainPathfinder.new()
	_pathfinder.setup(_graph)

	var train_data: TrainData = _catalog.get_train_by_id("freight_engine")
	var train_scene := preload("res://scenes/trains/train_entity.tscn")
	_train = train_scene.instantiate() as TrainEntity
	_train.setup(train_data, _pathfinder)
	_world.add_child(_train)

	await get_tree().process_frame


# ============================================================================
# Test 1: Spawn at city coordinate
# ============================================================================

func _test_01_spawn_at_city() -> void:
	var kolkata: Vector2i = _cities["kolkata"]
	_train.reset_to(kolkata)
	var expected_world: Vector2 = WorldMap.grid_to_world(kolkata)

	if _train.position.is_equal_approx(expected_world):
		_results["spawn_at_city"] = true
		print("[PASS] Spawn at city: train at correct world position")
	else:
		_results["spawn_at_city"] = false
		_issues.append("Train position %s != expected %s" % [_train.position, expected_world])
		print("[FAIL] Spawn at city: wrong position")


# ============================================================================
# Test 2: Pathfinder returns valid path Kolkata -> Dacca
# ============================================================================

func _test_02_path_kolkata_to_dacca() -> void:
	var kolkata: Vector2i = _cities["kolkata"]
	var dacca: Vector2i = _cities["dacca"]
	var result: TrackPathResult = _pathfinder.find_path(kolkata, dacca)

	if result.success and result.coords.size() >= 2:
		_results["path_kolkata_dacca"] = true
		print("[PASS] Path Kolkata -> Dacca: %d coords, %.1f km" % [result.coords.size(), result.total_length_km])
	else:
		_results["path_kolkata_dacca"] = false
		_issues.append("Path failed: %s" % result.error_message)
		print("[FAIL] Path Kolkata -> Dacca: %s" % result.error_message)


# ============================================================================
# Test 3: Train moves from first to second coordinate
# ============================================================================

func _test_03_train_moves_along_path() -> void:
	var kolkata: Vector2i = _cities["kolkata"]
	var patna: Vector2i = _cities["patna"]

	_train.reset_to(kolkata)
	var ok := _train.set_route(kolkata, patna)
	if not ok:
		_results["train_moves"] = false
		_issues.append("Failed to set route Kolkata -> Patna")
		print("[FAIL] Train moves: could not set route")
		return

	var start_pos := _train.position
	_train.start_movement()

	# Wait a short time for movement to begin
	await get_tree().create_timer(0.1).timeout

	var moved := not _train.position.is_equal_approx(start_pos)
	_train._movement.stop()

	if moved:
		_results["train_moves"] = true
		print("[PASS] Train moves: position changed after start")
	else:
		_results["train_moves"] = false
		_issues.append("Train did not move from start position")
		print("[FAIL] Train moves: position unchanged")


# ============================================================================
# Test 4: Multi-segment path (Kolkata -> Dacca has intermediate)
# ============================================================================

func _test_04_multi_segment_path() -> void:
	var kolkata: Vector2i = _cities["kolkata"]
	var dacca: Vector2i = _cities["dacca"]
	var result: TrackPathResult = _pathfinder.find_path(kolkata, dacca)

	if result.success and result.coords.size() > 2:
		_results["multi_segment"] = true
		print("[PASS] Multi-segment path: %d coords (intermediate stops exist)" % result.coords.size())
	else:
		_results["multi_segment"] = false
		_issues.append("Path has %d coords, expected > 2" % result.coords.size())
		print("[FAIL] Multi-segment path: only %d coords" % result.coords.size())


# ============================================================================
# Test 5: Train stops at destination
# ============================================================================

func _test_05_train_stops_at_destination() -> void:
	var kolkata: Vector2i = _cities["kolkata"]
	var murshidabad: Vector2i = _cities["murshidabad"]

	_train.reset_to(kolkata)
	var ok := _train.set_route(kolkata, murshidabad)
	if not ok:
		_results["stops_at_destination"] = false
		_issues.append("Could not set route for stop test")
		print("[FAIL] Stops at destination: route failed")
		return

	_arrival_count = 0
	_train._movement.destination_arrived.connect(_on_test_arrival, CONNECT_ONE_SHOT)
	_train.start_movement()

	# Wait for arrival (Kolkata->Murshidabad is ~14 grid units, ~343 world px, ~4.3 sec at 80 px/s)
	await get_tree().create_timer(8.0).timeout

	var stopped := not _train.is_moving()
	var arrived := _arrival_count > 0

	if stopped and arrived:
		_results["stops_at_destination"] = true
		print("[PASS] Stops at destination: train arrived and stopped")
	else:
		_results["stops_at_destination"] = false
		_issues.append("stopped=%s, arrived=%s" % [stopped, arrived])
		print("[FAIL] Stops at destination: stopped=%s, arrived=%s" % [stopped, arrived])


func _on_test_arrival(_coord: Vector2i) -> void:
	_arrival_count += 1


func _on_self_arrival(_coord: Vector2i) -> void:
	_self_arrived = true


# ============================================================================
# Test 6: Missing path fails gracefully
# ============================================================================

func _test_06_missing_path_fails_gracefully() -> void:
	var isolated_start := Vector2i(5, 5)
	var isolated_end := Vector2i(50, 50)
	_graph.add_node(isolated_start)
	_graph.add_node(isolated_end)

	var result: TrackPathResult = _pathfinder.find_path(isolated_start, isolated_end)

	if not result.success:
		_results["missing_path_fails"] = true
		print("[PASS] Missing path fails gracefully: %s" % result.error_message)
	else:
		_results["missing_path_fails"] = false
		_issues.append("Disconnected nodes somehow had a path")
		print("[FAIL] Missing path: unexpectedly succeeded")


# ============================================================================
# Test 7: Empty path fails
# ============================================================================

func _test_07_empty_path_fails() -> void:
	var ok := _train._movement.set_path([])
	if not ok:
		_results["empty_path_fails"] = true
		print("[PASS] Empty path fails: rejected")
	else:
		_results["empty_path_fails"] = false
		_issues.append("Empty path was accepted")
		print("[FAIL] Empty path: was accepted")


# ============================================================================
# Test 8: Self-path (start == destination) immediate arrival
# ============================================================================

func _test_08_self_path_immediate_arrival() -> void:
	var kolkata: Vector2i = _cities["kolkata"]
	_self_arrived = false

	_train.reset_to(kolkata)
	_train._movement.reset()

	var result: TrackPathResult = _pathfinder.find_path(kolkata, kolkata)
	if not result.success or result.coords.size() != 1:
		_results["self_path"] = false
		_issues.append("Self-path graph query failed")
		print("[FAIL] Self-path: graph query failed")
		return

	var ok := _train._movement.set_path(result.coords)
	if not ok:
		_results["self_path"] = false
		_issues.append("Self-path movement set_path failed")
		print("[FAIL] Self-path: set_path rejected valid single-coord path")
		return

	_train._movement.destination_arrived.connect(_on_self_arrival, CONNECT_ONE_SHOT)
	_train.start_movement()

	# Give one frame for the immediate arrival to process
	await get_tree().process_frame

	if _self_arrived and not _train.is_moving():
		_results["self_path"] = true
		print("[PASS] Self-path: immediate arrival emitted, not moving")
	else:
		_results["self_path"] = false
		_issues.append("self_arrived=%s, is_moving=%s" % [_self_arrived, _train.is_moving()])
		print("[FAIL] Self-path: self_arrived=%s, is_moving=%s" % [_self_arrived, _train.is_moving()])


# ============================================================================
# Test 9: Train rotates to face direction
# ============================================================================

func _test_09_train_rotates_to_face_direction() -> void:
	var kolkata: Vector2i = _cities["kolkata"]
	var murshidabad: Vector2i = _cities["murshidabad"]

	_train.reset_to(kolkata)
	_train.set_route(kolkata, murshidabad)
	var start_rotation := _train.rotation
	_train.start_movement()

	await get_tree().create_timer(0.5).timeout
	var moved_rotation := _train.rotation
	_train._movement.stop()

	if not is_equal_approx(start_rotation, moved_rotation):
		_results["train_rotates"] = true
		print("[PASS] Train rotates: rotation changed from %.2f to %.2f" % [start_rotation, moved_rotation])
	else:
		_results["train_rotates"] = false
		_issues.append("Rotation did not change during movement")
		print("[FAIL] Train rotates: rotation unchanged")


# ============================================================================
# Test 10: No scope creep
# ============================================================================

func _test_10_no_scope_creep() -> void:
	var forbidden_dirs := ["ai", "events", "ui"]
	var creep_found := false

	for dir_name in forbidden_dirs:
		var subdir := DirAccess.open("res://src/" + dir_name)
		if subdir != null:
			subdir.list_dir_begin()
			var item: String = subdir.get_next()
			while item != "":
				if item != "." and item != ".." and not item.ends_with(".tmp"):
					creep_found = true
					_issues.append("Scope creep: res://src/" + dir_name + "/" + item)
				item = subdir.get_next()

	_results["no_scope_creep"] = not creep_found
	if not creep_found:
		print("[PASS] No scope creep: no unauthorized systems added")
	else:
		print("[FAIL] No scope creep: unauthorized files found")


# ============================================================================
# Report
# ============================================================================

func _print_report() -> void:
	print("")
	print("========================================")
	print("SPRINT 05 ACCEPTANCE VERIFICATION REPORT")
	print("========================================")
	print("")
	print("Spawn at city:         %s" % str(_results.get("spawn_at_city", false)))
	print("Path Kolkata->Dacca:   %s" % str(_results.get("path_kolkata_dacca", false)))
	print("Train moves:           %s" % str(_results.get("train_moves", false)))
	print("Multi-segment path:    %s" % str(_results.get("multi_segment", false)))
	print("Stops at destination:  %s" % str(_results.get("stops_at_destination", false)))
	print("Missing path fails:    %s" % str(_results.get("missing_path_fails", false)))
	print("Empty path fails:      %s" % str(_results.get("empty_path_fails", false)))
	print("Self-path arrival:     %s" % str(_results.get("self_path", false)))
	print("Train rotates:         %s" % str(_results.get("train_rotates", false)))
	print("No scope creep:        %s" % str(_results.get("no_scope_creep", false)))
	print("")

	if _issues.is_empty():
		print("Issues found: None")
	else:
		print("Issues found:")
		for issue in _issues:
			print("  - %s" % issue)

	print("")
	var all_pass := true
	for key in _results.keys():
		if not _results[key]:
			all_pass = false
			break

	if all_pass:
		print("ALL CHECKS PASSED — Sprint 05 complete")
	else:
		print("SOME CHECKS FAILED — Sprint 05 incomplete")

	print("")
	print("========================================")
	get_tree().quit()
