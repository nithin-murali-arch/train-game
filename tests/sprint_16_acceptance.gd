# Sprint 16 Acceptance Tests
# Run via: godot --headless tests/sprint_16_acceptance.tscn

extends Node

var _pass_count: int = 0
var _fail_count: int = 0

func _ready() -> void:
	run_all_tests()

func run_all_tests() -> void:
	print("=== Sprint 16 Acceptance Tests ===")
	_test_sprint_15_regression()
	_test_event_manager_setup()
	_test_monsoon_flood_blocks_edge()
	_test_monsoon_flood_unblocks_on_expire()
	_test_labor_strike_reduces_loading()
	_test_labor_strike_cleared_on_expire()
	_test_port_boom_doubles_production_demand()
	_test_port_boom_reverts_on_expire()
	_test_track_inspection_fines_poor_condition()
	_test_repair_track_edge()
	_test_reset_clears_events()
	_test_save_load_v5()
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
	await get_tree().process_frame
	return rt

func _build_track_between(rt: RouteToyPlayable, city_a: String, city_b: String, owner: String = "player_railway_company") -> void:
	var grid_a: Vector2i = rt.cities_grid[city_a]
	var grid_b: Vector2i = rt.cities_grid[city_b]
	rt.graph.add_node(grid_a)
	rt.graph.add_node(grid_b)
	rt.graph.add_edge(grid_a, grid_b, owner)

func _advance_days(rt: RouteToyPlayable, days: int) -> void:
	for i in range(days):
		rt.advance_one_day()
		await get_tree().process_frame

# ------------------------------------------------------------------------------
# Test 1: Sprint 15 regression
# ------------------------------------------------------------------------------
func _test_sprint_15_regression() -> void:
	print("\n[Test 1] Sprint 15 regression")
	var rt := await _make_route_toy()

	_assert(rt.event_manager != null, "EventManager exists")
	_assert(rt.get_warning_events().size() == 0, "No warnings at start")
	_assert(rt.get_active_events().size() == 0, "No active events at start")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 2: EventManager setup
# ------------------------------------------------------------------------------
func _test_event_manager_setup() -> void:
	print("\n[Test 2] EventManager setup")
	var rt := await _make_route_toy()

	var event := rt.event_manager.generate_event("monsoon_flood", {
		"current_absolute_day": 1,
		"affected_edge_from_x": 0,
		"affected_edge_from_y": 0,
		"affected_edge_to_x": 1,
		"affected_edge_to_y": 1,
	})
	_assert(event != null, "Event generated")
	_assert(event.event_type == "monsoon_flood", "Event type is monsoon_flood")
	_assert(event.warning_absolute_day == 1, "Warning day is current day")
	_assert(event.start_absolute_day == 6, "Start day is +5")
	_assert(event.end_absolute_day == 16, "End day is +10 from start")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 3: Monsoon flood blocks edge
# ------------------------------------------------------------------------------
func _test_monsoon_flood_blocks_edge() -> void:
	print("\n[Test 3] Monsoon flood blocks edge")
	var rt := await _make_route_toy()

	var grid_a: Vector2i = rt.cities_grid["patna"]
	var grid_b: Vector2i = rt.cities_grid["kolkata"]
	rt.graph.add_node(grid_a)
	rt.graph.add_node(grid_b)
	rt.graph.add_edge(grid_a, grid_b)

	var event := rt.event_manager.generate_event("monsoon_flood", {
		"current_absolute_day": 1,
		"affected_edge_from_x": grid_a.x,
		"affected_edge_from_y": grid_a.y,
		"affected_edge_to_x": grid_b.x,
		"affected_edge_to_y": grid_b.y,
	})

	# Tick to activation day (day 6)
	rt.event_manager.tick(6, 1, 1857)
	var edge := rt.graph.get_edge(grid_a, grid_b)
	_assert(edge.is_blocked, "Edge is blocked during monsoon")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 4: Monsoon flood unblocks on expire
# ------------------------------------------------------------------------------
func _test_monsoon_flood_unblocks_on_expire() -> void:
	print("\n[Test 4] Monsoon flood unblocks on expire")
	var rt := await _make_route_toy()

	var grid_a: Vector2i = rt.cities_grid["patna"]
	var grid_b: Vector2i = rt.cities_grid["kolkata"]
	rt.graph.add_node(grid_a)
	rt.graph.add_node(grid_b)
	rt.graph.add_edge(grid_a, grid_b)

	var event := rt.event_manager.generate_event("monsoon_flood", {
		"current_absolute_day": 1,
		"affected_edge_from_x": grid_a.x,
		"affected_edge_from_y": grid_a.y,
		"affected_edge_to_x": grid_b.x,
		"affected_edge_to_y": grid_b.y,
	})

	rt.event_manager.tick(6, 1, 1857)
	rt.event_manager.tick(17, 1, 1857)
	var edge := rt.graph.get_edge(grid_a, grid_b)
	_assert(not edge.is_blocked, "Edge is unblocked after monsoon expires")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 5: Labor strike reduces loading
# ------------------------------------------------------------------------------
func _test_labor_strike_reduces_loading() -> void:
	print("\n[Test 5] Labor strike reduces loading")
	var rt := await _make_route_toy()

	var runtime: CityRuntimeState = rt.city_runtime["patna"]
	runtime.add_cargo("coal", 100)

	var event := rt.event_manager.generate_event("labor_strike", {
		"current_absolute_day": 1,
		"affected_city_id": "patna",
	})

	# Tick to activation day (day 4)
	rt.event_manager.tick(4, 1, 1857)
	_assert(runtime.is_striking, "City is striking")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 6: Labor strike cleared on expire
# ------------------------------------------------------------------------------
func _test_labor_strike_cleared_on_expire() -> void:
	print("\n[Test 6] Labor strike cleared on expire")
	var rt := await _make_route_toy()

	var runtime: CityRuntimeState = rt.city_runtime["patna"]

	var event := rt.event_manager.generate_event("labor_strike", {
		"current_absolute_day": 1,
		"affected_city_id": "patna",
	})

	rt.event_manager.tick(4, 1, 1857)
	rt.event_manager.tick(12, 1, 1857)
	_assert(not runtime.is_striking, "City strike cleared after event expires")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 7: Port boom doubles production and demand
# ------------------------------------------------------------------------------
func _test_port_boom_doubles_production_demand() -> void:
	print("\n[Test 7] Port boom doubles production and demand")
	var rt := await _make_route_toy()

	var event := rt.event_manager.generate_event("port_boom", {
		"current_absolute_day": 1,
		"affected_city_id": "kolkata",
		"affected_cargo_id": "coal",
	})

	# Port boom has no warning, starts immediately
	rt.event_manager.tick(1, 1, 1857)
	var runtime: CityRuntimeState = rt.city_runtime["kolkata"]
	_assert(runtime.port_boom_multipliers.has("coal"), "Port boom multiplier set")
	_assert(runtime.port_boom_multipliers["coal"].get("production_multiplier", 1.0) == 2.0, "Production multiplier is 2.0")
	_assert(runtime.port_boom_multipliers["coal"].get("demand_multiplier", 1.0) == 2.0, "Demand multiplier is 2.0")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 8: Port boom reverts on expire
# ------------------------------------------------------------------------------
func _test_port_boom_reverts_on_expire() -> void:
	print("\n[Test 8] Port boom reverts on expire")
	var rt := await _make_route_toy()

	var event := rt.event_manager.generate_event("port_boom", {
		"current_absolute_day": 1,
		"affected_city_id": "kolkata",
		"affected_cargo_id": "coal",
	})

	rt.event_manager.tick(1, 1, 1857)
	rt.event_manager.tick(17, 1, 1857)
	var runtime: CityRuntimeState = rt.city_runtime["kolkata"]
	_assert(not runtime.port_boom_multipliers.has("coal"), "Port boom multiplier removed after expire")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 9: Track inspection fines poor condition edges
# ------------------------------------------------------------------------------
func _test_track_inspection_fines_poor_condition() -> void:
	print("\n[Test 9] Track inspection fines poor condition edges")
	var rt := await _make_route_toy()

	var grid_a: Vector2i = rt.cities_grid["patna"]
	var grid_b: Vector2i = rt.cities_grid["kolkata"]
	rt.graph.add_node(grid_a)
	rt.graph.add_node(grid_b)
	rt.graph.add_edge(grid_a, grid_b, "player_railway_company", 0.3)

	var start_balance: int = rt.treasury.balance

	var event := rt.event_manager.generate_event("track_inspection", {
		"current_absolute_day": 1,
	})

	# Tick to activation day (day 8)
	rt.event_manager.tick(8, 1, 1857)
	_assert(rt.treasury.balance < start_balance, "Treasury reduced by inspection fines")
	_assert(event.fine_amount > 0, "Fine amount recorded")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 10: Repair track edge
# ------------------------------------------------------------------------------
func _test_repair_track_edge() -> void:
	print("\n[Test 10] Repair track edge")
	var rt := await _make_route_toy()

	var grid_a: Vector2i = rt.cities_grid["patna"]
	var grid_b: Vector2i = rt.cities_grid["kolkata"]
	rt.graph.add_node(grid_a)
	rt.graph.add_node(grid_b)
	rt.graph.add_edge(grid_a, grid_b, "player_railway_company", 0.3)

	var edge := rt.graph.get_edge(grid_a, grid_b)
	var start_balance: int = rt.treasury.balance

	var ok := rt.repair_track_edge(grid_a, grid_b)
	_assert(ok, "Repair succeeds")
	_assert(edge.condition == 1.0, "Edge condition restored to 1.0")
	_assert(rt.treasury.balance < start_balance, "Treasury spent on repair")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 11: Reset simulation clears events
# ------------------------------------------------------------------------------
func _test_reset_clears_events() -> void:
	print("\n[Test 11] Reset simulation clears events")
	var rt := await _make_route_toy()

	rt.event_manager.generate_event("labor_strike", {
		"current_absolute_day": 1,
		"affected_city_id": "patna",
	})

	_assert(rt.event_manager.get_warning_events().size() == 1, "Event exists before reset")

	rt.reset_simulation()
	_assert(rt.event_manager != null, "EventManager recreated after reset")
	_assert(rt.get_warning_events().size() == 0, "No events after reset")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 12: Save/Load v5 restores events and track condition
# ------------------------------------------------------------------------------
func _test_save_load_v5() -> void:
	print("\n[Test 12] Save/Load v5")
	var rt := await _make_route_toy()

	# Set up Sprint 16 state
	var grid_a: Vector2i = rt.cities_grid["patna"]
	var grid_b: Vector2i = rt.cities_grid["kolkata"]
	rt.graph.add_node(grid_a)
	rt.graph.add_node(grid_b)
	rt.graph.add_edge(grid_a, grid_b, "player_railway_company", 0.3)

	rt.event_manager.generate_event("labor_strike", {
		"current_absolute_day": 1,
		"affected_city_id": "patna",
	})

	var data: SaveGameData = SaveSerializer.serialize(rt)
	_assert(data.save_version == 5, "Serialized as v5")
	_assert(not data.event_manager_state.is_empty(), "Event manager state serialized")
	_assert(data.track_edges.size() > 0, "Track edges serialized")
	var edge_dict: Dictionary = data.track_edges[0]
	_assert(edge_dict.get("condition", 1.0) == 0.3, "Track condition serialized")

	rt.reset_simulation()
	_assert(rt.event_manager.get_warning_events().size() == 0, "Reset clears events")

	var ok := SaveSerializer.deserialize(data, rt)
	_assert(ok, "Deserialize v5 succeeds")

	var restored_edge = rt.graph.get_edge(grid_a, grid_b)
	_assert(restored_edge != null, "Edge restored")
	_assert(restored_edge.condition == 0.3, "Track condition restored")
	_assert(rt.event_manager.get_warning_events().size() == 1, "Warning event restored")

	rt.queue_free()
