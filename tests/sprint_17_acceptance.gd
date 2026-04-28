# Sprint 17 Acceptance Tests
# Run via: godot --headless tests/sprint_17_acceptance.tscn

extends Node

# Preload Sprint 17 types so parser resolves class members on RouteToyPlayable
const CampaignManager := preload("res://src/campaign/campaign_manager.gd")
const CampaignObjective := preload("res://src/campaign/campaign_objective.gd")
const CampaignData := preload("res://src/campaign/campaign_data.gd")
const ScenarioData := preload("res://src/campaign/scenario_data.gd")
const AudioManager := preload("res://src/audio/audio_manager.gd")

var _pass_count: int = 0
var _fail_count: int = 0

func _ready() -> void:
	run_all_tests()

func run_all_tests() -> void:
	print("=== Sprint 17 Acceptance Tests ===")
	_test_sprint_13_regression()
	_test_sprint_14_regression()
	_test_sprint_15_regression()
	_test_sprint_16_regression()
	_test_campaign_starts()
	_test_act_1_tracks_progress()
	_test_objective_completion_advances_act()
	_test_contract_objective_works()
	_test_upgrade_objective_works()
	_test_market_share_objective_works()
	_test_event_survival_objective_works()
	_test_scenario_starts()
	_test_faction_selection_applies_bonus()
	_test_save_load_v6()
	_test_audio_manager_exists()
	_test_main_menu_can_start_sandbox()
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

func _build_track_between(rt: RouteToyPlayable, city_a: String, city_b: String) -> void:
	var grid_a: Vector2i = rt.cities_grid[city_a]
	var grid_b: Vector2i = rt.cities_grid[city_b]
	rt.graph.add_node(grid_a)
	rt.graph.add_node(grid_b)
	rt.graph.add_edge(grid_a, grid_b, "player_railway_company")

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
	_assert(data.save_version == 6, "Save version is 6")
	rt.reset_simulation()
	var ok := SaveSerializer.deserialize(data, rt)
	_assert(ok, "Deserialize works")
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
	var contract := ContractRuntimeState.new()
	contract.contract_id = "s17_test"
	contract.cargo_id = "coal"
	contract.destination_city_id = "kolkata"
	contract.required_quantity = 10
	contract.reward_money = 100
	contract.reputation_reward = 5
	contract.status = ContractRuntimeState.Status.ACCEPTED
	rt.contract_manager._accepted.append(contract)
	rt.contract_manager.record_delivery("coal", "kolkata", 10)
	_assert(rt.reputation > 0, "Reputation increased")
	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 3: Sprint 15 regression
# ------------------------------------------------------------------------------
func _test_sprint_15_regression() -> void:
	print("\n[Test 3] Sprint 15 regression")
	var rt := await _make_route_toy()
	_assert(rt.faction_manager != null, "FactionManager exists")
	_assert(rt.baron_ai != null, "BaronAI exists")
	_assert(rt.delivery_ledger != null, "DeliveryLedger exists")
	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 4: Sprint 16 regression
# ------------------------------------------------------------------------------
func _test_sprint_16_regression() -> void:
	print("\n[Test 4] Sprint 16 regression")
	var rt := await _make_route_toy()
	_assert(rt.event_manager != null, "EventManager exists")
	rt.event_manager.generate_event("labor_strike", {"current_absolute_day": 1, "affected_city_id": "patna"})
	_assert(rt.event_manager.get_warning_events().size() == 1, "Event generated")
	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 5: Campaign starts
# ------------------------------------------------------------------------------
func _test_campaign_starts() -> void:
	print("\n[Test 5] Campaign starts")
	var rt := await _make_route_toy()
	rt.start_campaign("bengal_railway_charter")
	_assert(rt.campaign_manager != null, "CampaignManager created")
	_assert(rt.campaign_manager.get_current_act() != null, "Current act exists")
	_assert(rt.campaign_manager.get_current_objectives().size() > 0, "Objectives exist")
	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 6: Act 1 objective tracks progress
# ------------------------------------------------------------------------------
func _test_act_1_tracks_progress() -> void:
	print("\n[Test 6] Act 1 tracks progress")
	var rt := await _make_route_toy()
	rt.start_campaign("bengal_railway_charter")
	var objectives := rt.campaign_manager.get_current_objectives()
	var build_track_obj: CampaignObjective = null
	for obj in objectives:
		if obj.type == "build_track":
			build_track_obj = obj
			break
	_assert(build_track_obj != null, "build_track objective found")
	_assert(build_track_obj.current_value == 0, "Starts at 0")
	_build_track_between(rt, "patna", "kolkata")
	rt.campaign_manager.tick_objectives(rt)
	_assert(build_track_obj.current_value >= 1, "Progress tracked after building track")
	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 7: Objective completion advances act
# ------------------------------------------------------------------------------
func _test_objective_completion_advances_act() -> void:
	print("\n[Test 7] Objective completion advances act")
	var rt := await _make_route_toy()
	rt.start_campaign("bengal_railway_charter")
	var start_act_id := rt.campaign_manager.get_current_act().act_id
	# Complete all Act 1 objectives
	_build_track_between(rt, "patna", "kolkata")
	rt.purchase_train("freight_engine", "patna")
	rt.create_route({"train_index": 0, "origin_city_id": "patna", "destination_city_id": "kolkata", "cargo_id": "coal", "loop_enabled": true, "return_empty": true})
	rt.campaign_manager.tick_objectives(rt)
	# Force advance if all complete
	var all_complete := true
	for obj in rt.campaign_manager.get_current_objectives():
		if not obj.is_complete:
			all_complete = false
			break
	if all_complete:
		rt.campaign_manager.advance_act()
	var new_act_id := rt.campaign_manager.get_current_act().act_id
	_assert(new_act_id != start_act_id, "Act advanced after completion")
	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 8: Contract objective works
# ------------------------------------------------------------------------------
func _test_contract_objective_works() -> void:
	print("\n[Test 8] Contract objective works")
	var rt := await _make_route_toy()
	rt.start_campaign("bengal_railway_charter")
	# Jump to Act 2 by completing Act 1
	_build_track_between(rt, "patna", "kolkata")
	rt.purchase_train("freight_engine", "patna")
	rt.create_route({"train_index": 0, "origin_city_id": "patna", "destination_city_id": "kolkata", "cargo_id": "coal", "loop_enabled": true, "return_empty": true})
	rt.campaign_manager.tick_objectives(rt)
	rt.campaign_manager.advance_act()
	# Now in Act 2: complete_contract target
	var contract_obj: CampaignObjective = null
	for obj in rt.campaign_manager.get_current_objectives():
		if obj.type == "complete_contract":
			contract_obj = obj
			break
	if contract_obj != null:
		var contract := ContractRuntimeState.new()
		contract.contract_id = "camp_test"
		contract.cargo_id = "coal"
		contract.destination_city_id = "kolkata"
		contract.required_quantity = 10
		contract.status = ContractRuntimeState.Status.COMPLETED
		rt.contract_manager._completed.append(contract)
		rt.campaign_manager.tick_objectives(rt)
		_assert(contract_obj.current_value >= 1, "Contract completion tracked")
	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 9: Upgrade objective works
# ------------------------------------------------------------------------------
func _test_upgrade_objective_works() -> void:
	print("\n[Test 9] Upgrade objective works")
	var rt := await _make_route_toy()
	rt.start_campaign("bengal_railway_charter")
	# Complete Act 1 and 2 to reach Act 3
	_build_track_between(rt, "patna", "kolkata")
	rt.purchase_train("freight_engine", "patna")
	rt.create_route({"train_index": 0, "origin_city_id": "patna", "destination_city_id": "kolkata", "cargo_id": "coal", "loop_enabled": true, "return_empty": true})
	rt.campaign_manager.tick_objectives(rt)
	rt.campaign_manager.advance_act()  # Act 1 -> 2
	rt.campaign_manager.advance_act()  # Act 2 -> 3
	var upgrade_obj: CampaignObjective = null
	for obj in rt.campaign_manager.get_current_objectives():
		if obj.type == "upgrade_station":
			upgrade_obj = obj
			break
	if upgrade_obj != null:
		var upgrades: StationUpgradeState = rt.station_upgrades["patna"]
		upgrades.upgrade_warehouse()
		rt.campaign_manager.tick_objectives(rt)
		_assert(upgrade_obj.current_value >= 1, "Upgrade tracked")
	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 10: Market share objective works
# ------------------------------------------------------------------------------
func _test_market_share_objective_works() -> void:
	print("\n[Test 10] Market share objective works")
	var rt := await _make_route_toy()
	rt.start_campaign("bengal_railway_charter")
	# Jump to Act 4
	for i in range(3):
		rt.campaign_manager.advance_act()
	var ms_obj: CampaignObjective = null
	for obj in rt.campaign_manager.get_current_objectives():
		if obj.type == "reach_market_share":
			ms_obj = obj
			break
	if ms_obj != null:
		rt.delivery_ledger.record_delivery(1, FactionManager.FACTION_PLAYER, "r1", "t1", "patna", "kolkata", "coal", 100, 1500, 100)
		rt.delivery_ledger.record_delivery(1, FactionManager.FACTION_BRITISH, "r2", "t2", "patna", "kolkata", "coal", 100, 1500, 100)
		rt.campaign_manager.tick_objectives(rt)
		_assert(ms_obj.current_value == 50, "Market share at 50%")
	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 11: Event survival objective works
# ------------------------------------------------------------------------------
func _test_event_survival_objective_works() -> void:
	print("\n[Test 11] Event survival objective works")
	var rt := await _make_route_toy()
	rt.start_campaign("bengal_railway_charter")
	# Jump to Act 5
	for i in range(4):
		rt.campaign_manager.advance_act()
	var surv_obj: CampaignObjective = null
	for obj in rt.campaign_manager.get_current_objectives():
		if obj.type == "survive_event":
			surv_obj = obj
			break
	if surv_obj != null:
		# Add an active negative event first
		rt.event_manager.generate_event("monsoon_flood", {"current_absolute_day": 1, "affected_edge_from": Vector2i(0,0), "affected_edge_to": Vector2i(1,1)})
		var ev = rt.event_manager.get_warning_events()[0]
		ev.status = EventRuntimeState.Status.ACTIVE
		rt.event_manager._warning_events.clear()
		rt.event_manager._active_events.append(ev)
		rt.campaign_manager.tick_objectives(rt)
		_assert(surv_obj.current_value == 0, "Not surviving during active flood")
		# Clear the active event
		rt.event_manager._active_events.clear()
		rt.campaign_manager.tick_objectives(rt)
		_assert(surv_obj.current_value == 1, "Survived after flood cleared")
	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 12: Scenario starts with correct state
# ------------------------------------------------------------------------------
func _test_scenario_starts() -> void:
	print("\n[Test 12] Scenario starts")
	var rt := await _make_route_toy()
	rt.start_scenario("port_monopoly")
	_assert(rt.scenario_data != null, "Scenario data loaded")
	_assert(rt.scenario_data.starting_money == 100000, "Port monopoly config has 100k")
	_assert(rt.treasury.balance > 50000, "Port monopoly has substantial capital after train purchases")
	_assert(rt.owned_trains.size() == 2, "Port monopoly starts with 2 trains")
	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 13: Faction selection applies bonus
# ------------------------------------------------------------------------------
func _test_faction_selection_applies_bonus() -> void:
	print("\n[Test 13] Faction bonus applied")
	var rt := await _make_route_toy()
	rt.selected_faction_id = "british"
	rt._setup_treasury()
	_assert(rt.treasury.balance == 60000, "British starts with 60k")

	rt.selected_faction_id = "amdani"
	rt._setup_treasury()
	_assert(rt.treasury.balance == 45000, "Amdani starts with 45k")
	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 14: Save/Load v6 preserves campaign/scenario/faction
# ------------------------------------------------------------------------------
func _test_save_load_v6() -> void:
	print("\n[Test 14] Save/Load v6")
	var rt := await _make_route_toy()
	rt.selected_faction_id = "french"
	rt.start_campaign("bengal_railway_charter")
	_build_track_between(rt, "patna", "kolkata")
	rt.campaign_manager.tick_objectives(rt)

	var data: SaveGameData = SaveSerializer.serialize(rt)
	_assert(data.save_version == 6, "Serialized as v6")
	_assert(data.selected_faction_id == "french", "Faction serialized")
	_assert(not data.campaign_state.is_empty(), "Campaign state serialized")

	rt.reset_simulation()
	var ok := SaveSerializer.deserialize(data, rt)
	_assert(ok, "Deserialize v6 succeeds")
	_assert(rt.selected_faction_id == "french", "Faction restored")
	_assert(rt.campaign_manager != null, "Campaign manager restored")

	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 15: Audio manager exists
# ------------------------------------------------------------------------------
func _test_audio_manager_exists() -> void:
	print("\n[Test 15] Audio manager exists")
	var rt := await _make_route_toy()
	_assert(rt.audio_manager != null, "AudioManager exists")
	rt.queue_free()

# ------------------------------------------------------------------------------
# Test 16: Main menu can start sandbox
# ------------------------------------------------------------------------------
func _test_main_menu_can_start_sandbox() -> void:
	print("\n[Test 16] Main menu sandbox")
	var rt := await _make_route_toy()
	rt.start_sandbox()
	_assert(rt.campaign_manager == null, "Sandbox has no campaign")
	_assert(rt.scenario_data == null, "Sandbox has no scenario")
	_assert(rt.treasury.balance > 0, "Sandbox has starting capital")
	rt.queue_free()
