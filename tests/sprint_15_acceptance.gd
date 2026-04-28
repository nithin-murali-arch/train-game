# Sprint 15 Acceptance Tests
# Run via: godot --headless tests/sprint_15_acceptance.tscn

extends Node

var _pass_count: int = 0
var _fail_count: int = 0

func _ready() -> void:
	run_all_tests()

func run_all_tests() -> void:
	print("=== Sprint 15 Acceptance Tests ===")
	_test_sprint_13_regression()
	_test_sprint_14_regression()
	_test_faction_manager_initializes()
	_test_british_ai_initializes()
	_test_british_ai_evaluates_route()
	_test_british_ai_builds_track()
	_test_british_ai_buys_train()
	_test_british_ai_creates_route()
	_test_british_ai_completes_delivery()
	_test_delivery_ledger_player()
	_test_delivery_ledger_british()
	_test_market_share_updates()
	_test_track_ownership_assigned()
	_test_open_foreign_track_charges_toll()
	_test_private_foreign_track_blocks()
	_test_save_load_v4()
	_test_event_manager_exists()
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
# Test 1: Sprint 13 regression
# ------------------------------------------------------------------------------
func _test_sprint_13_regression() -> void:
	print("\n[Test 1] Sprint 13 regression")
	var rt := await _make_route_toy()

	_build_track_between(rt, "patna", "kolkata")
	rt.purchase_train("freight_engine", "patna")
	rt.create_route({"train_index": 0, "origin_city_id": "patna", "destination_city_id": "kolkata", "cargo_id": "coal", "loop_enabled": true, "return_empty": true})

	_assert(rt.owned_trains.size() == 1, "One train owned")
	_assert(rt.active_runners.size() == 1, "One runner active")

	var data: SaveGameData = SaveSerializer.serialize(rt)
	_assert(data != null, "Serialize works")
	_assert(data.save_version == 5, "Save version is 5")

	rt.reset_simulation()
	_assert(rt.owned_trains.is_empty(), "Reset clears trains")

	var ok := SaveSerializer.deserialize(data, rt)
	_assert(ok, "Deserialize works")
	_assert(rt.owned_trains.size() == 1, "Loaded 1 train")
	_assert(rt.active_runners.size() == 1, "Loaded 1 route")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 2: Sprint 14 regression
# ------------------------------------------------------------------------------
func _test_sprint_14_regression() -> void:
	print("\n[Test 2] Sprint 14 regression")
	var rt := await _make_route_toy()

	rt.contract_manager.generate_contracts_if_needed(1, 1, 1857)
	var available := rt.contract_manager.get_available_contracts()
	_assert(available.size() > 0, "Contracts generated")

	var contract_id: String = available[0].contract_id
	var ok := rt.contract_manager.accept_contract(contract_id, 1, 1, 1857)
	_assert(ok, "Contract accepted")

	var start_rep: int = rt.reputation
	var contract := ContractRuntimeState.new()
	contract.contract_id = "test_s15_001"
	contract.cargo_id = "coal"
	contract.destination_city_id = "kolkata"
	contract.required_quantity = 10
	contract.reward_money = 100
	contract.reputation_reward = 5
	contract.status = ContractRuntimeState.Status.ACCEPTED
	rt.contract_manager._accepted.append(contract)

	rt.contract_manager.record_delivery("coal", "kolkata", 10)
	_assert(rt.reputation == start_rep + 5, "Reputation increased")

	var upgrades: StationUpgradeState = rt.station_upgrades["patna"]
	var cost: int = upgrades.get_warehouse_cost()
	rt.treasury.spend(cost)
	upgrades.upgrade_warehouse()
	_assert(upgrades.warehouse_level == 1, "Warehouse upgrade works")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 3: FactionManager initializes player and British
# ------------------------------------------------------------------------------
func _test_faction_manager_initializes() -> void:
	print("\n[Test 3] FactionManager initializes")
	var rt := await _make_route_toy()

	_assert(rt.faction_manager != null, "FactionManager exists")
	_assert(rt.faction_manager.get_balance(FactionManager.FACTION_PLAYER) > 0, "Player has treasury")
	_assert(rt.faction_manager.get_balance(FactionManager.FACTION_BRITISH) > 0, "British has treasury")
	_assert(rt.treasury != null, "Legacy treasury exists")
	_assert(rt.treasury.balance == rt.faction_manager.get_balance(FactionManager.FACTION_PLAYER), "Legacy treasury matches player")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 4: British AI initializes with treasury
# ------------------------------------------------------------------------------
func _test_british_ai_initializes() -> void:
	print("\n[Test 4] British AI initializes")
	var rt := await _make_route_toy()

	_assert(rt.baron_ai != null, "BaronAI exists")
	_assert(rt.get_ai_state_name() == "ANALYZE", "AI starts in ANALYZE")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 5: British AI evaluates valid route
# ------------------------------------------------------------------------------
func _test_british_ai_evaluates_route() -> void:
	print("\n[Test 5] British AI evaluates route")
	var rt := await _make_route_toy()

	# Pre-build track so AI sees a path
	_build_track_between(rt, "patna", "kolkata", FactionManager.FACTION_BRITISH)

	rt.baron_ai.tick(1, 1, 1857)
	_assert(rt.baron_ai.get_state_name() == "BUY_TRAIN", "AI skips to BUY_TRAIN when track exists")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 6: British AI builds track
# ------------------------------------------------------------------------------
func _test_british_ai_builds_track() -> void:
	print("\n[Test 6] British AI builds track")
	var rt := await _make_route_toy()

	var start_balance: int = rt.faction_manager.get_balance(FactionManager.FACTION_BRITISH)
	var start_edges: int = rt.graph.get_edge_count()

	# Tick AI twice: ANALYZE → BUILD_TRACK → BUY_TRAIN
	rt.baron_ai.tick(1, 1, 1857)
	rt.baron_ai.tick(1, 1, 1857)

	_assert(rt.graph.get_edge_count() > start_edges, "AI built track")
	_assert(rt.faction_manager.get_balance(FactionManager.FACTION_BRITISH) < start_balance, "British treasury spent on track")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 7: British AI buys/spawns train
# ------------------------------------------------------------------------------
func _test_british_ai_buys_train() -> void:
	print("\n[Test 7] British AI buys train")
	var rt := await _make_route_toy()

	var start_balance: int = rt.faction_manager.get_balance(FactionManager.FACTION_BRITISH)

	# Tick through BUILD_TRACK and BUY_TRAIN
	rt.baron_ai.tick(1, 1, 1857)
	rt.baron_ai.tick(1, 1, 1857)
	rt.baron_ai.tick(1, 1, 1857)

	_assert(rt.ai_trains.size() == 1, "AI owns one train")
	_assert(rt.ai_trains[0].instance_id == "ai_train_001", "AI train has correct ID")
	_assert(rt.faction_manager.get_balance(FactionManager.FACTION_BRITISH) < start_balance, "British treasury spent")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 8: British AI creates route
# ------------------------------------------------------------------------------
func _test_british_ai_creates_route() -> void:
	print("\n[Test 8] British AI creates route")
	var rt := await _make_route_toy()

	# Tick through all setup states
	for i in range(4):
		rt.baron_ai.tick(1, 1, 1857)

	_assert(rt.ai_runners.size() == 1, "AI has one runner")
	_assert(rt.baron_ai.get_state_name() == "OPERATE", "AI reaches OPERATE state")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 9: British AI completes delivery
# ------------------------------------------------------------------------------
func _test_british_ai_completes_delivery() -> void:
	print("\n[Test 9] British AI completes delivery")
	var rt := await _make_route_toy()

	# Tick AI through setup
	for i in range(4):
		rt.baron_ai.tick(1, 1, 1857)

	_assert(rt.ai_runners.size() == 1, "AI runner exists")

	# Simulate a delivery by using the runner's own stats
	var runner: RouteRunner = rt.ai_runners[0]
	runner.get_stats().record_trip(50, 750, 100)
	runner.trip_completed.emit(runner.get_stats())

	# Check ledger has British entries
	var british_entries := rt.delivery_ledger.get_entries_for_faction(FactionManager.FACTION_BRITISH)
	_assert(british_entries.size() > 0, "Ledger has British delivery entries")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 10: DeliveryLedger records player delivery
# ------------------------------------------------------------------------------
func _test_delivery_ledger_player() -> void:
	print("\n[Test 10] DeliveryLedger records player delivery")
	var rt := await _make_route_toy()

	_build_track_between(rt, "patna", "kolkata")
	rt.purchase_train("freight_engine", "patna")
	rt.create_route({"train_index": 0, "origin_city_id": "patna", "destination_city_id": "kolkata", "cargo_id": "coal", "loop_enabled": true, "return_empty": true})

	# Simulate a delivery by using the runner's own stats
	var runner: RouteRunner = rt.active_runners[0]
	runner.get_stats().record_trip(100, 1500, 200)
	runner.trip_completed.emit(runner.get_stats())

	var player_entries := rt.delivery_ledger.get_entries_for_faction(FactionManager.FACTION_PLAYER)
	_assert(player_entries.size() > 0, "Ledger has player delivery entries")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 11: DeliveryLedger records British delivery
# ------------------------------------------------------------------------------
func _test_delivery_ledger_british() -> void:
	print("\n[Test 11] DeliveryLedger records British delivery")
	var rt := await _make_route_toy()

	for i in range(4):
		rt.baron_ai.tick(1, 1, 1857)

	var runner: RouteRunner = rt.ai_runners[0] if rt.ai_runners.size() > 0 else null
	_assert(runner != null, "AI runner created")

	# Simulate a delivery by using the runner's own stats
	runner.get_stats().record_trip(50, 750, 100)
	runner.trip_completed.emit(runner.get_stats())

	var british_entries := rt.delivery_ledger.get_entries_for_faction(FactionManager.FACTION_BRITISH)
	_assert(british_entries.size() > 0, "Ledger has British delivery entries")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 12: Market share updates after deliveries
# ------------------------------------------------------------------------------
func _test_market_share_updates() -> void:
	print("\n[Test 12] Market share updates")
	var rt := await _make_route_toy()

	_assert(rt.get_player_market_share() == 0.0, "Player market share starts at 0")

	# Simulate player delivery
	rt.delivery_ledger.record_delivery(1, FactionManager.FACTION_PLAYER, "route_001", "train_001", "patna", "kolkata", "coal", 100, 1500, 100)

	var player_share := rt.get_player_market_share()
	_assert(player_share == 1.0, "Player has 100% share after sole delivery")

	# Simulate British delivery
	rt.delivery_ledger.record_delivery(1, FactionManager.FACTION_BRITISH, "ai_route_001", "ai_train_001", "patna", "kolkata", "coal", 100, 1500, 100)

	player_share = rt.get_player_market_share()
	_assert(player_share == 0.5, "Player share drops to 50%")

	var kolkata_share := rt.get_city_market_share("kolkata")
	_assert(kolkata_share == 0.5, "Player has 50% share in Kolkata")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 13: Track ownership assigned correctly
# ------------------------------------------------------------------------------
func _test_track_ownership_assigned() -> void:
	print("\n[Test 13] Track ownership")
	var rt := await _make_route_toy()

	var grid_a: Vector2i = rt.cities_grid["patna"]
	var grid_b: Vector2i = rt.cities_grid["kolkata"]
	rt.graph.add_node(grid_a)
	rt.graph.add_node(grid_b)

	# Player builds track
	rt.graph.add_edge(grid_a, grid_b, FactionManager.FACTION_PLAYER)
	var edge: TrackEdgeData = rt.graph.get_edge(grid_a, grid_b)
	_assert(edge != null, "Edge exists")
	_assert(edge.owner_faction_id == FactionManager.FACTION_PLAYER, "Player owns track")

	# AI builds track
	var grid_c: Vector2i = rt.cities_grid["dacca"]
	rt.graph.add_node(grid_c)
	rt.graph.add_edge(grid_b, grid_c, FactionManager.FACTION_BRITISH)
	var edge2: TrackEdgeData = rt.graph.get_edge(grid_b, grid_c)
	_assert(edge2.owner_faction_id == FactionManager.FACTION_BRITISH, "British owns track")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 14: Open foreign track charges toll
# ------------------------------------------------------------------------------
func _test_open_foreign_track_charges_toll() -> void:
	print("\n[Test 14] Open foreign track charges toll")
	var rt := await _make_route_toy()

	var grid_a: Vector2i = rt.cities_grid["patna"]
	var grid_b: Vector2i = rt.cities_grid["kolkata"]
	rt.graph.add_node(grid_a)
	rt.graph.add_node(grid_b)

	# British builds track with open access and toll
	rt.graph.add_edge(grid_a, grid_b, FactionManager.FACTION_BRITISH, 1.0, 10.0, "open")

	# Player tries to find path
	var path_result: TrackPathResult = rt.graph.find_path(grid_a, grid_b, FactionManager.FACTION_PLAYER)
	_assert(path_result.success, "Player can use open British track")

	var toll: int = rt.graph.calculate_path_toll(path_result.coords, FactionManager.FACTION_PLAYER)
	_assert(toll > 0, "Toll is charged for open foreign track")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 15: Private foreign track blocks route
# ------------------------------------------------------------------------------
func _test_private_foreign_track_blocks() -> void:
	print("\n[Test 15] Private foreign track blocks route")
	var rt := await _make_route_toy()

	var grid_a: Vector2i = rt.cities_grid["patna"]
	var grid_b: Vector2i = rt.cities_grid["kolkata"]
	rt.graph.add_node(grid_a)
	rt.graph.add_node(grid_b)

	# British builds track as private
	rt.graph.add_edge(grid_a, grid_b, FactionManager.FACTION_BRITISH, 1.0, 0.0, "private")

	# Player tries to find path
	var path_result: TrackPathResult = rt.graph.find_path(grid_a, grid_b, FactionManager.FACTION_PLAYER)
	_assert(not path_result.success, "Player cannot use private British track")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 16: Save/load v4 restores faction, AI, ledger, ownership
# ------------------------------------------------------------------------------
func _test_save_load_v4() -> void:
	print("\n[Test 16] Save/Load v4")
	var rt := await _make_route_toy()

	# Set Sprint 15 state
	rt.faction_manager.spend_money(FactionManager.FACTION_PLAYER, 10000)
	rt.faction_manager.add_money(FactionManager.FACTION_BRITISH, 5000)
	rt.delivery_ledger.record_delivery(1, FactionManager.FACTION_PLAYER, "r1", "t1", "patna", "kolkata", "coal", 50, 750, 50)

	var data: SaveGameData = SaveSerializer.serialize(rt)
	_assert(data.save_version == 5, "Serialized as v5")
	_assert(not data.faction_state.is_empty(), "Faction state serialized")
	_assert(data.delivery_ledger.size() > 0, "Delivery ledger serialized")

	var player_before: int = rt.faction_manager.get_balance(FactionManager.FACTION_PLAYER)
	var british_before: int = rt.faction_manager.get_balance(FactionManager.FACTION_BRITISH)

	rt.reset_simulation()
	_assert(rt.faction_manager.get_balance(FactionManager.FACTION_PLAYER) == 50000, "Reset restores default player capital")

	var ok := SaveSerializer.deserialize(data, rt)
	_assert(ok, "Deserialize v4 succeeds")
	_assert(rt.faction_manager.get_balance(FactionManager.FACTION_PLAYER) == player_before, "Player treasury restored")
	_assert(rt.faction_manager.get_balance(FactionManager.FACTION_BRITISH) == british_before, "British treasury restored")
	_assert(rt.delivery_ledger.get_total_quantity() == 50, "Delivery ledger restored")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 17: Sprint 16 event manager exists and is set up
# ------------------------------------------------------------------------------
func _test_event_manager_exists() -> void:
	print("\n[Test 17] Sprint 16 event manager exists")
	var rt := await _make_route_toy()

	_assert(rt.event_manager != null, "EventManager exists")
	_assert(rt.get_warning_events().size() == 0, "No warning events at start")
	_assert(rt.get_active_events().size() == 0, "No active events at start")

	# CampaignManager should not exist
	var has_campaign_manager: bool = false
	for child in rt.get_children():
		if child.get_script() != null and child.get_script().resource_path.find("campaign_manager") != -1:
			has_campaign_manager = true
	_assert(not has_campaign_manager, "No CampaignManager exists")

	rt.queue_free()
