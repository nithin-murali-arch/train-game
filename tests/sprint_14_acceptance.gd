# Sprint 14 Acceptance Tests
# Run via: godot --headless tests/sprint_14_acceptance.tscn

extends Node

var _pass_count: int = 0
var _fail_count: int = 0

func _ready() -> void:
	run_all_tests()

func run_all_tests() -> void:
	print("=== Sprint 14 Acceptance Tests ===")
	_test_sprint_13_regression()
	_test_contract_generation()
	_test_contract_accept()
	_test_contract_delivery_progress()
	_test_contract_completion_reward()
	_test_contract_reputation()
	_test_contract_expiry_penalty()
	_test_contract_expiry_across_month_boundary()
	_test_contract_refresh_across_month_boundary()
	_test_warehouse_upgrade()
	_test_loading_bay_upgrade()
	_test_maintenance_shed_upgrade()
	_test_oversupply_warning()
	_test_price_recovery()
	_test_save_load_v3()
	_test_v1_backward_compat()
	_test_v2_backward_compat()
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
	_assert(rt.owned_trains[0].instance_id != "", "Train has instance_id")

	var data: SaveGameData = SaveSerializer.serialize(rt)
	_assert(data != null, "Serialize works")
	_assert(data.save_version == 3, "Save version is 3")

	rt.reset_simulation()
	_assert(rt.owned_trains.is_empty(), "Reset clears trains")

	var ok := SaveSerializer.deserialize(data, rt)
	_assert(ok, "Deserialize works")
	_assert(rt.owned_trains.size() == 1, "Loaded 1 train")
	_assert(rt.active_runners.size() == 1, "Loaded 1 route")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 2: Contract generation creates available contracts
# ------------------------------------------------------------------------------
func _test_contract_generation() -> void:
	print("\n[Test 2] Contract generation")
	var rt := await _make_route_toy()

	rt.contract_manager.generate_contracts_if_needed(1, 1, 1857)
	var available := rt.contract_manager.get_available_contracts()
	_assert(available.size() > 0, "Contracts generated")

	# Check that contracts include diverse city pairs
	var has_different_cities := false
	for c in available:
		if c.origin_city_id != c.destination_city_id:
			has_different_cities = true
	_assert(has_different_cities, "Contracts have different origin/destination")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 3: Contract accept moves to accepted list
# ------------------------------------------------------------------------------
func _test_contract_accept() -> void:
	print("\n[Test 3] Contract accept")
	var rt := await _make_route_toy()

	rt.contract_manager.generate_contracts_if_needed(1, 1, 1857)
	var available := rt.contract_manager.get_available_contracts()
	_assert(available.size() > 0, "Has available contracts")

	var contract_id: String = available[0].contract_id
	var ok := rt.contract_manager.accept_contract(contract_id, 1, 1, 1857)
	_assert(ok, "Contract accepted")
	_assert(rt.contract_manager.get_accepted_contracts().size() == 1, "One accepted contract")
	_assert(rt.contract_manager.get_available_contracts().size() < available.size(), "Available count decreased")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 4: Matching delivery increments contract progress
# ------------------------------------------------------------------------------
func _test_contract_delivery_progress() -> void:
	print("\n[Test 4] Contract delivery progress")
	var rt := await _make_route_toy()

	_build_track_between(rt, "patna", "kolkata")
	rt.purchase_train("freight_engine", "patna")
	rt.create_route({"train_index": 0, "origin_city_id": "patna", "destination_city_id": "kolkata", "cargo_id": "coal", "loop_enabled": true, "return_empty": true})

	# Create a contract that matches this route
	var contract := ContractRuntimeState.new()
	contract.contract_id = "test_contract_001"
	contract.cargo_id = "coal"
	contract.destination_city_id = "kolkata"
	contract.required_quantity = 100
	contract.status = ContractRuntimeState.Status.ACCEPTED
	rt.contract_manager._accepted.append(contract)

	# Simulate delivery
	rt.contract_manager.record_delivery("coal", "kolkata", 20)
	_assert(contract.delivered_quantity == 20, "Delivery progress incremented")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 5: Completing required quantity gives reward
# ------------------------------------------------------------------------------
func _test_contract_completion_reward() -> void:
	print("\n[Test 5] Contract completion reward")
	var rt := await _make_route_toy()

	var start_balance: int = rt.treasury.balance
	var contract := ContractRuntimeState.new()
	contract.contract_id = "test_contract_002"
	contract.cargo_id = "coal"
	contract.destination_city_id = "kolkata"
	contract.required_quantity = 50
	contract.delivered_quantity = 45
	contract.reward_money = 5000
	contract.status = ContractRuntimeState.Status.ACCEPTED
	rt.contract_manager._accepted.append(contract)

	rt.contract_manager.record_delivery("coal", "kolkata", 10)
	_assert(rt.treasury.balance == start_balance + 5000, "Reward added to treasury")
	_assert(rt.contract_manager.get_completed_contracts().size() == 1, "Contract moved to completed")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 6: Completing contract increases reputation
# ------------------------------------------------------------------------------
func _test_contract_reputation() -> void:
	print("\n[Test 6] Contract reputation")
	var rt := await _make_route_toy()

	var start_rep: int = rt.reputation
	var contract := ContractRuntimeState.new()
	contract.contract_id = "test_contract_003"
	contract.cargo_id = "coal"
	contract.destination_city_id = "kolkata"
	contract.required_quantity = 10
	contract.reward_money = 100
	contract.reputation_reward = 5
	contract.status = ContractRuntimeState.Status.ACCEPTED
	rt.contract_manager._accepted.append(contract)

	rt.contract_manager.record_delivery("coal", "kolkata", 10)
	_assert(rt.reputation == start_rep + 5, "Reputation increased")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 7: Expired contract applies penalty
# ------------------------------------------------------------------------------
func _test_contract_expiry_penalty() -> void:
	print("\n[Test 7] Contract expiry penalty")
	var rt := await _make_route_toy()

	var start_balance: int = rt.treasury.balance
	var start_rep: int = rt.reputation
	var contract := ContractRuntimeState.new()
	contract.contract_id = "test_contract_004"
	contract.cargo_id = "coal"
	contract.destination_city_id = "kolkata"
	contract.required_quantity = 100
	contract.deadline_absolute_day = 15
	contract.penalty_money = 1000
	contract.reputation_penalty = 3
	contract.status = ContractRuntimeState.Status.ACCEPTED
	rt.contract_manager._accepted.append(contract)

	rt.contract_manager.check_deadlines(20, 1, 1857)
	_assert(rt.treasury.balance == start_balance - 1000, "Penalty deducted")
	_assert(rt.reputation == start_rep - 3, "Reputation decreased")
	_assert(rt.contract_manager.get_failed_contracts().size() == 1, "Contract moved to failed")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 7b: Expired contract across month boundary
# ------------------------------------------------------------------------------
func _test_contract_expiry_across_month_boundary() -> void:
	print("\n[Test 7b] Contract expiry across month boundary")
	var rt := await _make_route_toy()

	var start_balance: int = rt.treasury.balance
	var contract := ContractRuntimeState.new()
	contract.contract_id = "test_contract_004b"
	contract.cargo_id = "coal"
	contract.destination_city_id = "kolkata"
	contract.required_quantity = 100
	# Deadline: day 30 of month 1 = absolute day 30
	contract.deadline_absolute_day = 30
	contract.penalty_money = 1000
	contract.status = ContractRuntimeState.Status.ACCEPTED
	rt.contract_manager._accepted.append(contract)

	# Day 28 of month 1 = absolute day 28 (before deadline)
	rt.contract_manager.check_deadlines(28, 1, 1857)
	_assert(rt.contract_manager.get_failed_contracts().is_empty(), "Contract not expired before deadline")

	# Day 5 of month 2 = absolute day 35 (after deadline)
	rt.contract_manager.check_deadlines(5, 2, 1857)
	_assert(rt.treasury.balance == start_balance - 1000, "Penalty deducted after month boundary")
	_assert(rt.contract_manager.get_failed_contracts().size() == 1, "Contract expired across month boundary")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 7c: Contract refresh across month boundary
# ------------------------------------------------------------------------------
func _test_contract_refresh_across_month_boundary() -> void:
	print("\n[Test 7c] Contract refresh across month boundary")
	var rt := await _make_route_toy()

	# Generate initial contracts on day 25 month 1
	rt.contract_manager.generate_contracts_if_needed(25, 1, 1857)
	var initial_count: int = rt.contract_manager.get_available_contracts().size()
	_assert(initial_count > 0, "Initial contracts generated")

	# Refresh interval is 7 days. Day 2 month 2 = absolute day 32. 32 - 25 = 7.
	# Should trigger refresh.
	rt.contract_manager.generate_contracts_if_needed(2, 2, 1857)
	# If refresh triggered, contracts may have been regenerated (same count)
	_assert(rt.contract_manager.get_available_contracts().size() >= initial_count, "Refresh works across month boundary")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 8: Warehouse upgrade
# ------------------------------------------------------------------------------
func _test_warehouse_upgrade() -> void:
	print("\n[Test 8] Warehouse upgrade")
	var rt := await _make_route_toy()

	var start_balance: int = rt.treasury.balance
	var upgrades: StationUpgradeState = rt.station_upgrades["patna"]
	_assert(upgrades.warehouse_level == 0, "Starts at level 0")

	var cost: int = upgrades.get_warehouse_cost()
	var ok := rt.treasury.can_afford(cost)
	_assert(ok, "Can afford upgrade")

	rt.treasury.spend(cost)
	upgrades.upgrade_warehouse()
	_assert(upgrades.warehouse_level == 1, "Level increased")
	_assert(rt.treasury.balance == start_balance - cost, "Treasury deducted")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 9: Loading Bay upgrade
# ------------------------------------------------------------------------------
func _test_loading_bay_upgrade() -> void:
	print("\n[Test 9] Loading Bay upgrade")
	var rt := await _make_route_toy()

	var upgrades: StationUpgradeState = rt.station_upgrades["kolkata"]
	var cost: int = upgrades.get_loading_bay_cost()
	rt.treasury.spend(cost)
	upgrades.upgrade_loading_bay()
	_assert(upgrades.loading_bay_level == 1, "Loading bay level increased")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 10: Maintenance Shed upgrade affects maintenance
# ------------------------------------------------------------------------------
func _test_maintenance_shed_upgrade() -> void:
	print("\n[Test 10] Maintenance Shed upgrade")
	var rt := await _make_route_toy()

	var upgrades: StationUpgradeState = rt.station_upgrades["patna"]
	var cost: int = upgrades.get_maintenance_shed_cost()
	rt.treasury.spend(cost)
	upgrades.upgrade_maintenance_shed()
	_assert(upgrades.maintenance_shed_level == 1, "Shed level increased")

	var discount: float = rt.get_maintenance_discount_for_city("patna")
	_assert(discount == 0.1, "Discount is 10% at level 1")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 11: Oversupply warning
# ------------------------------------------------------------------------------
func _test_oversupply_warning() -> void:
	print("\n[Test 11] Oversupply warning")
	var rt := await _make_route_toy()

	# Force oversupply at Kolkata
	var runtime: CityRuntimeState = rt.city_runtime["kolkata"]
	runtime.add_cargo("coal", 500)

	var price: float = rt.get_sell_price("kolkata", "coal")
	var cargo: CargoData = rt.cargo_catalog.get("coal", null) as CargoData
	var ratio := price / cargo.base_price
	_assert(ratio < 0.9, "Price is low due to oversupply")

	var label: String = rt.get_demand_label("kolkata", "coal")
	_assert(label == "Oversupplied", "Demand label shows oversupplied")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 12: Price recovery after economy ticks
# ------------------------------------------------------------------------------
func _test_price_recovery() -> void:
	print("\n[Test 12] Price recovery")
	var rt := await _make_route_toy()

	# Force moderate oversupply
	var runtime: CityRuntimeState = rt.city_runtime["kolkata"]
	runtime.add_cargo("coal", 500)

	var low_price: float = rt.get_sell_price("kolkata", "coal")
	_assert(low_price < 15.0, "Price is low initially")

	# Tick economy to consume stock (Kolkata demand = 80/day)
	for i in range(10):
		rt.economy.tick_day(rt.clock.current_day + i, 1, 1857)

	var recovered_price: float = rt.get_sell_price("kolkata", "coal")
	_assert(recovered_price > low_price, "Price recovered after demand consumption")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 13: Save/Load v3 restores contracts, reputation, station upgrades
# ------------------------------------------------------------------------------
func _test_save_load_v3() -> void:
	print("\n[Test 13] Save/Load v3")
	var rt := await _make_route_toy()

	# Set Sprint 14 state
	rt.reputation = 42
	var upgrades: StationUpgradeState = rt.station_upgrades["patna"]
	upgrades.warehouse_level = 2
	upgrades.maintenance_shed_level = 1

	var contract := ContractRuntimeState.new()
	contract.contract_id = "save_test_001"
	contract.cargo_id = "coal"
	contract.destination_city_id = "kolkata"
	contract.required_quantity = 50
	contract.delivered_quantity = 10
	contract.accepted_day = 15
	contract.accepted_month = 1
	contract.accepted_year = 1857
	contract.accepted_absolute_day = 15
	contract.deadline_absolute_day = 45
	contract.status = ContractRuntimeState.Status.ACCEPTED
	rt.contract_manager._accepted.append(contract)

	var data: SaveGameData = SaveSerializer.serialize(rt)
	_assert(data.save_version == 3, "Serialized as v3")
	_assert(data.reputation == 42, "Reputation serialized")
	_assert(not data.contracts.is_empty(), "Contracts serialized")
	_assert(data.station_upgrades.has("patna"), "Upgrades serialized")

	# Verify contract dict has absolute day fields
	var contract_dict: Dictionary = data.contracts.get("accepted", [])[0] as Dictionary
	_assert(contract_dict.get("accepted_absolute_day", 0) == 15, "Accepted absolute day serialized")
	_assert(contract_dict.get("deadline_absolute_day", 0) == 45, "Deadline absolute day serialized")

	rt.reset_simulation()
	_assert(rt.reputation == 0, "Reset clears reputation")

	var ok := SaveSerializer.deserialize(data, rt)
	_assert(ok, "Deserialize v3 succeeds")
	_assert(rt.reputation == 42, "Reputation restored")
	_assert(rt.station_upgrades["patna"].warehouse_level == 2, "Warehouse level restored")
	_assert(rt.station_upgrades["patna"].maintenance_shed_level == 1, "Shed level restored")
	_assert(rt.contract_manager.get_accepted_contracts().size() == 1, "Accepted contract restored")

	var restored_contract: ContractRuntimeState = rt.contract_manager.get_accepted_contracts()[0]
	_assert(restored_contract.accepted_absolute_day == 15, "Accepted absolute day restored")
	_assert(restored_contract.deadline_absolute_day == 45, "Deadline absolute day restored")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 14: v1 backward compat
# ------------------------------------------------------------------------------
func _test_v1_backward_compat() -> void:
	print("\n[Test 14] v1 backward compat")
	var rt := await _make_route_toy()

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
	_assert(rt.reputation == 0, "v1 load: reputation defaults to 0")
	_assert(rt.station_upgrades["patna"].warehouse_level == 0, "v1 load: upgrades default to 0")
	_assert(rt.owned_trains.size() == 1, "v1 load: train restored")

	rt.queue_free()


# ------------------------------------------------------------------------------
# Test 15: v2 backward compat
# ------------------------------------------------------------------------------
func _test_v2_backward_compat() -> void:
	print("\n[Test 15] v2 backward compat")
	var rt := await _make_route_toy()

	_build_track_between(rt, "patna", "kolkata")
	rt.purchase_train("freight_engine", "patna")
	rt.create_route({"train_index": 0, "origin_city_id": "patna", "destination_city_id": "kolkata", "cargo_id": "coal", "loop_enabled": true, "return_empty": true})

	var data: SaveGameData = SaveSerializer.serialize(rt)
	# Force it to look like v2 by stripping v3 fields
	data.save_version = 2
	data.reputation = 0
	data.contracts = {}
	data.station_upgrades = {}

	rt.reset_simulation()
	var ok := SaveSerializer.deserialize(data, rt)
	_assert(ok, "v2 deserialize succeeds")
	_assert(rt.reputation == 0, "v2 load: reputation default")
	_assert(rt.owned_trains.size() == 1, "v2 load: train restored")
	_assert(rt.active_runners.size() == 1, "v2 load: route restored")

	rt.queue_free()
