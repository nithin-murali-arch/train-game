# Sprint 13 Hardening Acceptance Tests
# Run via Editor > Scene > Run Current Scene, or attach to a Node in a test scene.
# Prints PASS/FAIL to output.

extends Node

var _pass_count: int = 0
var _fail_count: int = 0

func _ready() -> void:
	run_all_tests()

func run_all_tests() -> void:
	print("=== Sprint 13 Hardening Acceptance Tests ===")
	_test_empty_start()
	_test_multi_train_purchase()
	_test_multi_route_creation()
	_test_save_load_preserves_assignments()
	_test_hud_queries_safe_with_zero_routes()
	_test_v1_backward_compat()
	_test_route_creation_preview()
	print("=== Results: %d passed, %d failed ===" % [_pass_count, _fail_count])
	get_tree().quit(_fail_count)


func _assert(condition: bool, message: String) -> void:
	if condition:
		_pass_count += 1
		print("  PASS: %s" % message)
	else:
		_fail_count += 1
		push_error("  FAIL: %s" % message)


func _make_route_toy() -> RouteToyPlayable:
	var rt := RouteToyPlayable.new()
	add_child(rt)
	# Wait a frame for _ready() to run
	await get_tree().process_frame
	return rt


func _build_track_between(rt: RouteToyPlayable, city_a: String, city_b: String) -> void:
	var grid_a: Vector2i = rt.cities_grid[city_a]
	var grid_b: Vector2i = rt.cities_grid[city_b]
	rt.graph.add_node(grid_a)
	rt.graph.add_node(grid_b)
	rt.graph.add_edge(grid_a, grid_b, "player_railway_company")


# ------------------------------------------------------------------------------
# Test 1: Empty start
# ------------------------------------------------------------------------------
func _test_empty_start() -> void:
	print("\n[Test 1] Empty start")
	var rt := await _make_route_toy()
	_assert(rt.owned_trains.is_empty(), "No trains at start")
	_assert(rt.active_runners.is_empty(), "No routes at start")
	_assert(rt.train_by_instance_id.is_empty(), "Train map empty at start")
	_assert(rt.route_by_instance_id.is_empty(), "Route map empty at start")
	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 2: Multi-train purchase with distinct instance IDs
# ------------------------------------------------------------------------------
func _test_multi_train_purchase() -> void:
	print("\n[Test 2] Multi-train purchase")
	var rt := await _make_route_toy()

	var ok1 := rt.purchase_train("freight_engine", "patna")
	_assert(ok1, "First train purchase succeeds")
	_assert(rt.owned_trains.size() == 1, "One train owned")
	_assert(not rt.owned_trains[0].instance_id.is_empty(), "First train has instance_id")

	var ok2 := rt.purchase_train("mixed_engine", "kolkata")
	_assert(ok2, "Second train purchase succeeds")
	_assert(rt.owned_trains.size() == 2, "Two trains owned")
	_assert(not rt.owned_trains[1].instance_id.is_empty(), "Second train has instance_id")
	_assert(rt.owned_trains[0].instance_id != rt.owned_trains[1].instance_id, "Train instance IDs are distinct")
	_assert(rt.train_by_instance_id.has(rt.owned_trains[0].instance_id), "First train in map")
	_assert(rt.train_by_instance_id.has(rt.owned_trains[1].instance_id), "Second train in map")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 3: Multi-route creation with correct train assignment
# ------------------------------------------------------------------------------
func _test_multi_route_creation() -> void:
	print("\n[Test 3] Multi-route creation")
	var rt := await _make_route_toy()

	# Build track
	_build_track_between(rt, "patna", "kolkata")

	# Buy two trains
	rt.purchase_train("freight_engine", "patna")
	rt.purchase_train("mixed_engine", "kolkata")

	# Create route 1: train 0, patna -> kolkata, coal
	var ok1 := rt.create_route({
		"train_index": 0,
		"origin_city_id": "patna",
		"destination_city_id": "kolkata",
		"cargo_id": "coal",
		"loop_enabled": true,
		"return_empty": true,
	})
	_assert(ok1, "First route creation succeeds")
	_assert(rt.active_runners.size() == 1, "One active runner")

	# Create route 2: train 1, kolkata -> patna, coal
	var ok2 := rt.create_route({
		"train_index": 1,
		"origin_city_id": "kolkata",
		"destination_city_id": "patna",
		"cargo_id": "coal",
		"loop_enabled": true,
		"return_empty": true,
	})
	_assert(ok2, "Second route creation succeeds")
	_assert(rt.active_runners.size() == 2, "Two active runners")

	# Verify instance IDs
	var sched0: RouteSchedule = rt.active_runners[0]._schedule
	var sched1: RouteSchedule = rt.active_runners[1]._schedule
	_assert(not sched0.instance_id.is_empty(), "Route 0 has instance_id")
	_assert(not sched1.instance_id.is_empty(), "Route 1 has instance_id")
	_assert(sched0.instance_id != sched1.instance_id, "Route instance IDs are distinct")
	_assert(rt.route_by_instance_id.has(sched0.instance_id), "Route 0 in map")
	_assert(rt.route_by_instance_id.has(sched1.instance_id), "Route 1 in map")

	# Verify train assignments
	var train0_id: String = rt.owned_trains[0].instance_id
	var train1_id: String = rt.owned_trains[1].instance_id
	_assert(sched0.assigned_train_instance_id == train0_id, "Route 0 assigned to train 0")
	_assert(sched1.assigned_train_instance_id == train1_id, "Route 1 assigned to train 1")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 4: Save/Load preserves trains, routes, and assignments
# ------------------------------------------------------------------------------
func _test_save_load_preserves_assignments() -> void:
	print("\n[Test 4] Save/Load preserves assignments")
	var rt := await _make_route_toy()

	_build_track_between(rt, "patna", "kolkata")
	rt.purchase_train("freight_engine", "patna")
	rt.purchase_train("mixed_engine", "kolkata")

	rt.create_route({
		"train_index": 0,
		"origin_city_id": "patna",
		"destination_city_id": "kolkata",
		"cargo_id": "coal",
		"loop_enabled": true,
		"return_empty": true,
	})
	rt.create_route({
		"train_index": 1,
		"origin_city_id": "kolkata",
		"destination_city_id": "patna",
		"cargo_id": "coal",
		"loop_enabled": true,
		"return_empty": true,
	})

	var orig_train_ids: Array[String] = []
	for t in rt.owned_trains:
		orig_train_ids.append(t.instance_id)
	var orig_route_ids: Array[String] = []
	var orig_assignments: Dictionary = {}
	for r in rt.active_runners:
		var s: RouteSchedule = r._schedule
		orig_route_ids.append(s.instance_id)
		orig_assignments[s.instance_id] = s.assigned_train_instance_id

	# Serialize
	var data: SaveGameData = SaveSerializer.serialize(rt)
	_assert(data != null, "Serialize returns data")
	_assert(data.trains.size() == 2, "Serialized 2 trains")
	_assert(data.routes.size() == 2, "Serialized 2 routes")

	# Reset
	rt.reset_simulation()
	_assert(rt.owned_trains.is_empty(), "Reset clears trains")
	_assert(rt.active_runners.is_empty(), "Reset clears routes")

	# Deserialize
	var ok := SaveSerializer.deserialize(data, rt)
	_assert(ok, "Deserialize succeeds")

	# Verify counts
	_assert(rt.owned_trains.size() == 2, "Loaded 2 trains")
	_assert(rt.active_runners.size() == 2, "Loaded 2 routes")

	# Verify train instance IDs preserved
	for i in range(2):
		_assert(rt.owned_trains[i].instance_id == orig_train_ids[i], "Train %d instance_id preserved" % i)

	# Verify route instance IDs and assignments preserved
	for i in range(2):
		var s: RouteSchedule = rt.active_runners[i]._schedule
		_assert(s.instance_id == orig_route_ids[i], "Route %d instance_id preserved" % i)
		_assert(s.assigned_train_instance_id == orig_assignments[s.instance_id], "Route %d assignment preserved" % i)

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 5: HUD queries safe with 0, 1, 2 routes
# ------------------------------------------------------------------------------
func _test_hud_queries_safe_with_zero_routes() -> void:
	print("\n[Test 5] HUD queries safe with zero routes")
	var rt := await _make_route_toy()

	_assert(rt.get_runner_count() == 0, "Runner count is 0")
	_assert(rt.get_runner_by_index(0) == null, "Runner by index 0 returns null")
	_assert(rt.get_runner_by_index(-1) == null, "Runner by index -1 returns null")
	_assert(rt.get_route_schedule_by_index(0) == null, "Schedule by index 0 returns null")
	_assert(rt.get_runner_stats() == null, "Runner stats null with no routes")
	_assert(rt.get_runner_state_name() == "No route", "Runner state name is 'No route'")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 6: v1 backward compatibility
# ------------------------------------------------------------------------------
func _test_v1_backward_compat() -> void:
	print("\n[Test 6] v1 backward compatibility")
	var rt := await _make_route_toy()

	# Manually build a v1-style save
	_build_track_between(rt, "patna", "kolkata")
	var data := SaveGameData.new()
	data.save_version = 1
	data.train_id = "freight_engine"
	data.train_grid_coord = {"x": rt.cities_grid["patna"].x, "y": rt.cities_grid["patna"].y}
	data.route_schedule = {
		"route_id": "patna_to_kolkata_coal",
		"origin_city_id": "patna",
		"destination_city_id": "kolkata",
		"cargo_id": "coal",
		"loop_enabled": true,
		"return_empty": true,
	}
	data.route_stats = {}
	data.runner_state = "IDLE"

	var ok := SaveSerializer.deserialize(data, rt)
	_assert(ok, "v1 deserialize succeeds")
	_assert(rt.owned_trains.size() == 1, "v1 loads 1 train")
	_assert(rt.active_runners.size() == 1, "v1 loads 1 route")

	var t: TrainEntity = rt.owned_trains[0]
	_assert(t.instance_id.begins_with("train_migrated_"), "v1 train gets migrated instance_id")

	var s: RouteSchedule = rt.active_runners[0]._schedule
	_assert(s.instance_id.begins_with("route_migrated_"), "v1 route gets migrated instance_id")
	_assert(s.assigned_train_instance_id == t.instance_id, "v1 route assigned to migrated train")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 7: Route creation preview returns expected fields
# ------------------------------------------------------------------------------
func _test_route_creation_preview() -> void:
	print("\n[Test 7] Route creation preview")
	var rt := await _make_route_toy()

	_build_track_between(rt, "patna", "kolkata")
	rt.purchase_train("freight_engine", "patna")

	var est: Dictionary = rt.get_path_estimate("patna", "kolkata", 0, "coal")
	_assert(est.valid, "Preview valid for connected cities")
	_assert(est.distance_km > 0, "Preview distance > 0")
	_assert(est.train_capacity_units > 0, "Preview capacity > 0")
	_assert(est.revenue_estimate >= 0, "Preview revenue >= 0")
	_assert(est.maintenance_per_day >= 0, "Preview maintenance >= 0")
	_assert(est.origin_stock >= 0, "Preview origin_stock >= 0")
	_assert(est.dest_price > 0, "Preview dest_price > 0")
	_assert(est.demand_ratio >= 0, "Preview demand_ratio >= 0")

	rt.queue_free()
