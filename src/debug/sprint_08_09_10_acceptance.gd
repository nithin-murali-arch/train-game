extends Node

## Sprint 08/09/10 Combined Acceptance Verification

const CITY_EDGES: Array[Array] = [
	["kolkata", "patna"],
	["kolkata", "murshidabad"],
	["murshidabad", "dacca"],
	["patna", "dacca"],
]

var _catalog: DataCatalog
var _cargo_catalog: Dictionary = {}
var _city_data_by_id: Dictionary = {}
var _city_runtime: Dictionary = {}
var _cities_grid: Dictionary = {}
var _treasury: TreasuryState
var _clock: SimulationClock
var _economy: EconomyTickSystem

var _results: Dictionary = {}
var _issues: Array[String] = []


func _ready() -> void:
	print("========================================")
	print("SPRINT 08/09/10 ACCEPTANCE VERIFICATION")
	print("========================================")
	print("")

	_setup_data()

	_test_01_clock_advances_days()
	_test_02_production_increases_stock()
	_test_03_demand_decreases_stock()
	_test_04_demand_cannot_go_negative()
	_test_05_stock_cannot_exceed_max()
	_test_06_city_data_immutable_after_tick()
	_test_07_shortage_price_above_base()
	_test_08_oversupply_price_below_base()
	_test_09_price_clamps_minimum()
	_test_10_price_clamps_maximum()
	_test_11_dynamic_transaction_pre_unload_price()
	_test_12_dynamic_revenue_calculation()
	_test_13_treasury_increases_from_sale()
	_test_14_maintenance_deducted()
	_test_15_treasury_never_negative()
	_test_16_missing_cargo_returns_zero()
	await _test_17_route_loads_moves_unloads()
	_test_18_route_records_stats()
	await _test_19_route_returns_to_origin()
	await _test_20_route_completes_three_trips()
	await _test_21_empty_origin_retries_on_day()
	await _test_22_no_path_fails_gracefully()
	_test_23_no_scope_creep()

	_print_report()


func _setup_data() -> void:
	_catalog = DataCatalog.new()
	for cargo in _catalog.cargos:
		_cargo_catalog[cargo.cargo_id] = cargo
	for city_id in ["kolkata", "patna", "dacca", "murshidabad"]:
		var city := _catalog.get_city_by_id(city_id)
		if city != null:
			_city_data_by_id[city_id] = city
			_cities_grid[city_id] = city.map_position
			var runtime := CityRuntimeState.new()
			runtime.setup_from_city_data(city, _cargo_catalog)
			_city_runtime[city_id] = runtime

	_treasury = TreasuryState.new(50000)
	_clock = SimulationClock.new()
	_economy = EconomyTickSystem.new()
	_economy.setup(_city_runtime, _city_data_by_id, _cargo_catalog)
	_clock.day_passed.connect(_economy.tick_day)


# ============================================================================
# Test 1: Clock advances days
# ============================================================================

func _test_01_clock_advances_days() -> void:
	_clock.current_day = 1
	_clock.advance_one_day()
	if _clock.current_day == 2:
		_results["clock_advances"] = true
		print("[PASS] Clock advances: day 1 -> 2")
	else:
		_results["clock_advances"] = false
		_issues.append("day expected 2, got %d" % _clock.current_day)
		print("[FAIL] Clock advances: expected day 2, got %d" % _clock.current_day)


# ============================================================================
# Test 2: Production increases stock
# ============================================================================

func _test_02_production_increases_stock() -> void:
	var patna: CityRuntimeState = _city_runtime["patna"]
	patna.remove_cargo("coal", patna.get_quantity("coal"))
	patna.add_cargo("coal", 500)

	var before := patna.get_quantity("coal")
	_clock.advance_one_day()
	var after := patna.get_quantity("coal")

	if after > before:
		_results["production_increases"] = true
		print("[PASS] Production increases: %d -> %d" % [before, after])
	else:
		_results["production_increases"] = false
		_issues.append("expected increase, %d -> %d" % [before, after])
		print("[FAIL] Production increases: %d -> %d" % [before, after])


# ============================================================================
# Test 3: Demand decreases stock
# ============================================================================

func _test_03_demand_decreases_stock() -> void:
	var kolkata: CityRuntimeState = _city_runtime["kolkata"]
	kolkata.remove_cargo("coal", kolkata.get_quantity("coal"))
	kolkata.add_cargo("coal", 500)

	var before := kolkata.get_quantity("coal")
	_clock.advance_one_day()
	var after := kolkata.get_quantity("coal")

	if after < before:
		_results["demand_decreases"] = true
		print("[PASS] Demand decreases: %d -> %d" % [before, after])
	else:
		_results["demand_decreases"] = false
		_issues.append("expected decrease, %d -> %d" % [before, after])
		print("[FAIL] Demand decreases: %d -> %d" % [before, after])


# ============================================================================
# Test 4: Demand cannot go below 0
# ============================================================================

func _test_04_demand_cannot_go_negative() -> void:
	var kolkata: CityRuntimeState = _city_runtime["kolkata"]
	kolkata.remove_cargo("coal", kolkata.get_quantity("coal"))
	# Kolkata has demand but no stock

	for i in range(5):
		_clock.advance_one_day()

	var qty := kolkata.get_quantity("coal")
	if qty == 0:
		_results["demand_not_negative"] = true
		print("[PASS] Demand not negative: stock stays at 0")
	else:
		_results["demand_not_negative"] = false
		_issues.append("expected 0, got %d" % qty)
		print("[FAIL] Demand not negative: expected 0, got %d" % qty)


# ============================================================================
# Test 5: Stock cannot exceed max_stock
# ============================================================================

func _test_05_stock_cannot_exceed_max() -> void:
	var patna: CityRuntimeState = _city_runtime["patna"]
	var patna_data: CityData = _city_data_by_id["patna"]
	var profile: CityCargoProfileData = _find_profile(patna_data, "coal")
	if profile == null:
		_results["stock_not_over_max"] = false
		_issues.append("no coal profile found")
		print("[FAIL] Stock not over max: no profile")
		return

	patna.remove_cargo("coal", patna.get_quantity("coal"))
	patna.add_cargo("coal", profile.max_stock - 1)

	for i in range(5):
		_clock.advance_one_day()

	var qty := patna.get_quantity("coal")
	if qty <= profile.max_stock:
		_results["stock_not_over_max"] = true
		print("[PASS] Stock not over max: %d <= %d" % [qty, profile.max_stock])
	else:
		_results["stock_not_over_max"] = false
		_issues.append("expected <= %d, got %d" % [profile.max_stock, qty])
		print("[FAIL] Stock not over max: %d > %d" % [qty, profile.max_stock])


# ============================================================================
# Test 6: Static CityData immutable after tick
# ============================================================================

func _test_06_city_data_immutable_after_tick() -> void:
	var fresh_catalog := DataCatalog.new()
	var fresh_patna: CityData = fresh_catalog.get_city_by_id("patna")
	var original := 0
	for profile in fresh_patna.cargo_profiles:
		if profile.cargo_id == "coal":
			original = profile.starting_stock
			break

	for i in range(3):
		_clock.advance_one_day()

	var check_catalog := DataCatalog.new()
	var check_patna: CityData = check_catalog.get_city_by_id("patna")
	var check := 0
	for profile in check_patna.cargo_profiles:
		if profile.cargo_id == "coal":
			check = profile.starting_stock
			break

	if check == original:
		_results["city_data_immutable"] = true
		print("[PASS] CityData immutable after tick")
	else:
		_results["city_data_immutable"] = false
		_issues.append("static stock changed %d -> %d" % [original, check])
		print("[FAIL] CityData immutable: changed %d -> %d" % [original, check])


# ============================================================================
# Test 7: Shortage price > base price
# ============================================================================

func _test_07_shortage_price_above_base() -> void:
	var kolkata: CityRuntimeState = _city_runtime["kolkata"]
	var kolkata_data: CityData = _city_data_by_id["kolkata"]
	kolkata.remove_cargo("coal", kolkata.get_quantity("coal"))
	kolkata.add_cargo("coal", 10)  # very low stock

	var price := MarketPricing.get_sell_price("coal", kolkata, kolkata_data, _cargo_catalog)
	var cargo: CargoData = _cargo_catalog["coal"] as CargoData

	if price > cargo.base_price:
		_results["shortage_price_high"] = true
		print("[PASS] Shortage price high: ₹%.0f > base ₹%.0f" % [price, cargo.base_price])
	else:
		_results["shortage_price_high"] = false
		_issues.append("expected > %.0f, got %.0f" % [cargo.base_price, price])
		print("[FAIL] Shortage price high: ₹%.0f <= base ₹%.0f" % [price, cargo.base_price])


# ============================================================================
# Test 8: Oversupply price < base price
# ============================================================================

func _test_08_oversupply_price_below_base() -> void:
	var kolkata: CityRuntimeState = _city_runtime["kolkata"]
	var kolkata_data: CityData = _city_data_by_id["kolkata"]
	kolkata.remove_cargo("coal", kolkata.get_quantity("coal"))
	kolkata.add_cargo("coal", 1000)  # very high stock

	var price := MarketPricing.get_sell_price("coal", kolkata, kolkata_data, _cargo_catalog)
	var cargo: CargoData = _cargo_catalog["coal"] as CargoData

	if price < cargo.base_price:
		_results["oversupply_price_low"] = true
		print("[PASS] Oversupply price low: ₹%.0f < base ₹%.0f" % [price, cargo.base_price])
	else:
		_results["oversupply_price_low"] = false
		_issues.append("expected < %.0f, got %.0f" % [cargo.base_price, price])
		print("[FAIL] Oversupply price low: ₹%.0f >= base ₹%.0f" % [price, cargo.base_price])


# ============================================================================
# Test 9: Price clamps at 0.5x minimum
# ============================================================================

func _test_09_price_clamps_minimum() -> void:
	var kolkata: CityRuntimeState = _city_runtime["kolkata"]
	var kolkata_data: CityData = _city_data_by_id["kolkata"]
	kolkata.remove_cargo("coal", kolkata.get_quantity("coal"))
	kolkata.add_cargo("coal", 99999)

	var price := MarketPricing.get_sell_price("coal", kolkata, kolkata_data, _cargo_catalog)
	var cargo: CargoData = _cargo_catalog["coal"] as CargoData
	var min_price := cargo.base_price * 0.5

	if is_equal_approx(price, min_price) or price >= min_price - 0.01:
		_results["price_clamp_min"] = true
		print("[PASS] Price clamp min: ₹%.0f >= 0.5x base" % price)
	else:
		_results["price_clamp_min"] = false
		_issues.append("expected >= %.0f, got %.0f" % [min_price, price])
		print("[FAIL] Price clamp min: ₹%.0f < 0.5x base" % price)


# ============================================================================
# Test 10: Price clamps at 2.0x maximum
# ============================================================================

func _test_10_price_clamps_maximum() -> void:
	var kolkata: CityRuntimeState = _city_runtime["kolkata"]
	var kolkata_data: CityData = _city_data_by_id["kolkata"]
	kolkata.remove_cargo("coal", kolkata.get_quantity("coal"))

	var price := MarketPricing.get_sell_price("coal", kolkata, kolkata_data, _cargo_catalog)
	var cargo: CargoData = _cargo_catalog["coal"] as CargoData
	var max_price := cargo.base_price * 2.0

	if is_equal_approx(price, max_price) or price <= max_price + 0.01:
		_results["price_clamp_max"] = true
		print("[PASS] Price clamp max: ₹%.0f <= 2.0x base" % price)
	else:
		_results["price_clamp_max"] = false
		_issues.append("expected <= %.0f, got %.0f" % [max_price, price])
		print("[FAIL] Price clamp max: ₹%.0f > 2.0x base" % price)


# ============================================================================
# Test 11: Dynamic transaction uses pre-unload price
# ============================================================================

func _test_11_dynamic_transaction_pre_unload_price() -> void:
	var kolkata: CityRuntimeState = _city_runtime["kolkata"]
	var kolkata_data: CityData = _city_data_by_id["kolkata"]
	kolkata.remove_cargo("coal", kolkata.get_quantity("coal"))
	kolkata.add_cargo("coal", 50)

	var treasury := TreasuryState.new(50000)
	var price_before := MarketPricing.get_sell_price("coal", kolkata, kolkata_data, _cargo_catalog)
	var result := Transaction.sell_cargo_dynamic("coal", 10, kolkata, kolkata_data, treasury, _cargo_catalog)

	if result.success and is_equal_approx(result.unit_price, price_before):
		_results["dynamic_pre_unload"] = true
		print("[PASS] Dynamic pre-unload price: ₹%.0f matches quoted price" % result.unit_price)
	else:
		_results["dynamic_pre_unload"] = false
		_issues.append("price mismatch or failed")
		print("[FAIL] Dynamic pre-unload price: mismatch")


# ============================================================================
# Test 12: Dynamic revenue = round(quantity × unit_price)
# ============================================================================

func _test_12_dynamic_revenue_calculation() -> void:
	var kolkata: CityRuntimeState = _city_runtime["kolkata"]
	var kolkata_data: CityData = _city_data_by_id["kolkata"]
	var treasury := TreasuryState.new(50000)
	var result := Transaction.sell_cargo_dynamic("coal", 100, kolkata, kolkata_data, treasury, _cargo_catalog)

	var expected := int(roundf(100.0 * result.unit_price))
	if result.success and result.revenue == expected:
		_results["dynamic_revenue"] = true
		print("[PASS] Dynamic revenue: %d × ₹%.0f = ₹%d" % [100, result.unit_price, result.revenue])
	else:
		_results["dynamic_revenue"] = false
		_issues.append("expected %d, got %d" % [expected, result.revenue])
		print("[FAIL] Dynamic revenue: expected ₹%d, got ₹%d" % [expected, result.revenue])


# ============================================================================
# Test 13: Treasury increases from sale
# ============================================================================

func _test_13_treasury_increases_from_sale() -> void:
	var treasury := TreasuryState.new(50000)
	var kolkata: CityRuntimeState = _city_runtime["kolkata"]
	var kolkata_data: CityData = _city_data_by_id["kolkata"]
	var before := treasury.balance
	var result := Transaction.sell_cargo_dynamic("coal", 100, kolkata, kolkata_data, treasury, _cargo_catalog)
	var after := treasury.balance

	if result.success and after > before:
		_results["treasury_increases"] = true
		print("[PASS] Treasury increases: ₹%d -> ₹%d" % [before, after])
	else:
		_results["treasury_increases"] = false
		_issues.append("treasury did not increase")
		print("[FAIL] Treasury increases: no increase")


# ============================================================================
# Test 14: Maintenance deducted
# ============================================================================

func _test_14_maintenance_deducted() -> void:
	var treasury := TreasuryState.new(50000)
	var before := treasury.balance
	treasury.add(3000)
	treasury.spend(50)
	var after := treasury.balance

	if after == before + 3000 - 50:
		_results["maintenance_deducted"] = true
		print("[PASS] Maintenance deducted: ₹%d -> ₹%d (-₹50)" % [before + 3000, after])
	else:
		_results["maintenance_deducted"] = false
		_issues.append("expected %d, got %d" % [before + 3000 - 50, after])
		print("[FAIL] Maintenance deducted: expected ₹%d, got ₹%d" % [before + 3000 - 50, after])


# ============================================================================
# Test 15: Treasury never negative
# ============================================================================

func _test_15_treasury_never_negative() -> void:
	var treasury := TreasuryState.new(100)
	var ok := treasury.spend(500)
	if not ok and treasury.balance == 100 and treasury.balance >= 0:
		_results["treasury_not_negative"] = true
		print("[PASS] Treasury not negative: overdraft rejected, balance = %d" % treasury.balance)
	else:
		_results["treasury_not_negative"] = false
		_issues.append("balance = %d" % treasury.balance)
		print("[FAIL] Treasury not negative: balance = %d" % treasury.balance)


# ============================================================================
# Test 16: Missing cargo returns zero
# ============================================================================

func _test_16_missing_cargo_returns_zero() -> void:
	var treasury := TreasuryState.new(50000)
	var kolkata: CityRuntimeState = _city_runtime["kolkata"]
	var kolkata_data: CityData = _city_data_by_id["kolkata"]
	var result := Transaction.sell_cargo_dynamic("fake_cargo", 10, kolkata, kolkata_data, treasury, _cargo_catalog)

	if not result.success and result.revenue == 0:
		_results["missing_cargo_zero"] = true
		print("[PASS] Missing cargo returns zero")
	else:
		_results["missing_cargo_zero"] = false
		_issues.append("revenue=%d" % result.revenue)
		print("[FAIL] Missing cargo: revenue=%d" % result.revenue)


# ============================================================================
# Test 17: Route loads, moves, unloads
# ============================================================================

func _test_17_route_loads_moves_unloads() -> void:
	var runner := _create_runner()
	runner.start_route()
	# Wait for at least 1 trip to complete (unload + sell + return)
	await _wait_for_trips(runner, 1, 25.0)

	if runner.get_stats().trips_completed >= 1:
		_results["route_loads_moves_unloads"] = true
		print("[PASS] Route loads/moves/unloads: 1 trip completed")
	else:
		_results["route_loads_moves_unloads"] = false
		_issues.append("trips=%d, state=%s" % [runner.get_stats().trips_completed, runner.get_state_name()])
		print("[FAIL] Route loads/moves/unloads: trips=%d, state=%s" % [runner.get_stats().trips_completed, runner.get_state_name()])


# ============================================================================
# Test 18: Route records stats
# ============================================================================

func _test_18_route_records_stats() -> void:
	var stats := RouteProfitStats.new()
	stats.record_trip(200, 5000, 50)

	if stats.trips_completed == 1 and stats.total_revenue == 5000 and stats.total_operating_cost == 50 and stats.total_profit == 4950:
		_results["route_records_stats"] = true
		print("[PASS] Route records stats: 1 trip, ₹5000 rev, ₹50 cost, ₹4950 profit")
	else:
		_results["route_records_stats"] = false
		_issues.append("stats mismatch")
		print("[FAIL] Route records stats: mismatch")


# ============================================================================
# Test 19: Route returns to origin
# ============================================================================

func _test_19_route_returns_to_origin() -> void:
	var runner := _create_runner()
	runner.start_route()
	# Wait for first trip to complete (runner loops, so it may start trip 2 before we check)
	await _wait_for_trips(runner, 1, 40.0)

	var completed_trip := runner.get_stats().trips_completed >= 1

	if completed_trip:
		_results["route_returns"] = true
		print("[PASS] Route returns to origin: %d trip(s) completed" % runner.get_stats().trips_completed)
	else:
		_results["route_returns"] = false
		_issues.append("state=%s, trips=%d" % [runner.get_state_name(), runner.get_stats().trips_completed])
		print("[FAIL] Route returns: state=%s, trips=%d" % [runner.get_state_name(), runner.get_stats().trips_completed])


# ============================================================================
# Test 20: Route completes 3 trips
# ============================================================================

func _test_20_route_completes_three_trips() -> void:
	var runner := _create_runner()
	var train_cargo: TrainCargo = runner._train.get_train_cargo()
	train_cargo.inventory.clear()

	var patna: CityRuntimeState = _city_runtime["patna"]
	patna.remove_cargo("coal", patna.get_quantity("coal"))
	patna.add_cargo("coal", 9999)

	var kolkata: CityRuntimeState = _city_runtime["kolkata"]
	kolkata.remove_cargo("coal", kolkata.get_quantity("coal"))

	runner.start_route()
	await _wait_for_trips(runner, 3, 60.0)

	if runner.get_stats().trips_completed >= 3:
		_results["three_trips"] = true
		print("[PASS] Three trips: %d completed" % runner.get_stats().trips_completed)
	else:
		_results["three_trips"] = false
		_issues.append("only %d trips" % runner.get_stats().trips_completed)
		print("[FAIL] Three trips: only %d completed" % runner.get_stats().trips_completed)


# ============================================================================
# Test 21: Empty origin retries on day
# ============================================================================

func _test_21_empty_origin_retries_on_day() -> void:
	var runner := _create_runner_with_stock({"patna": {"coal": 0}, "kolkata": {"coal": 50}})
	var train_cargo: TrainCargo = runner._train.get_train_cargo()
	train_cargo.inventory.clear()

	runner.start_route()
	await get_tree().create_timer(0.5).timeout

	var loading := runner._state == RouteRunner.State.LOADING_AT_ORIGIN
	var not_moving := not runner._train.is_moving()

	# Simulate a day passing with no cargo — should still be at origin
	runner.on_day_passed()
	await get_tree().create_timer(0.2).timeout

	var still_loading := runner._state == RouteRunner.State.LOADING_AT_ORIGIN

	if loading and not_moving and still_loading:
		_results["empty_origin_retries"] = true
		print("[PASS] Empty origin retries: waiting at origin")
	else:
		_results["empty_origin_retries"] = false
		_issues.append("state=%s, moving=%s" % [runner.get_state_name(), runner._train.is_moving()])
		print("[FAIL] Empty origin retries: state=%s" % runner.get_state_name())


# ============================================================================
# Test 22: No path fails gracefully
# ============================================================================

func _test_22_no_path_fails_gracefully() -> void:
	var runner := _create_runner_with_stock({"patna": {"coal": 600}, "kolkata": {"coal": 50}})
	# Use isolated graph with no edges connecting origin to destination
	var isolated_graph := TrackGraph.new()
	isolated_graph.add_node(_cities_grid["patna"])
	isolated_graph.add_node(_cities_grid["kolkata"])
	runner._graph = isolated_graph
	runner._pathfinder = TrainPathfinder.new()
	runner._pathfinder.setup(isolated_graph)
	# Update train's pathfinder too
	runner._train._pathfinder = runner._pathfinder

	var train_cargo: TrainCargo = runner._train.get_train_cargo()
	train_cargo.inventory.clear()

	runner.start_route()
	await get_tree().create_timer(2.0).timeout

	if runner._state == RouteRunner.State.FAILED:
		_results["no_path_fails"] = true
		print("[PASS] No path fails: route transitioned to FAILED")
	else:
		_results["no_path_fails"] = false
		_issues.append("state=%s" % runner.get_state_name())
		print("[FAIL] No path fails: state=%s" % runner.get_state_name())


# ============================================================================
# Test 23: No scope creep
# ============================================================================

func _test_23_no_scope_creep() -> void:
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
# Helpers
# ============================================================================

func _create_runner() -> RouteRunner:
	return _create_runner_with_stock({"patna": {"coal": 600}, "kolkata": {"coal": 50}})


func _create_runner_with_stock(stock_override: Dictionary) -> RouteRunner:
	# Create fresh runtime states so tests don't interfere with each other
	var fresh_runtime: Dictionary = {}
	for city_id in ["kolkata", "patna", "dacca", "murshidabad"]:
		var city_data: CityData = _city_data_by_id[city_id]
		if city_data == null:
			continue
		var runtime := CityRuntimeState.new()
		runtime.setup_from_city_data(city_data, _cargo_catalog)
		if stock_override.has(city_id):
			for cargo_id in stock_override[city_id].keys():
				runtime.remove_cargo(cargo_id, runtime.get_quantity(cargo_id))
				runtime.add_cargo(cargo_id, stock_override[city_id][cargo_id])
		fresh_runtime[city_id] = runtime

	var world := preload("res://scenes/world/world.tscn").instantiate()
	add_child(world)

	var graph := TrackGraph.new()
	for pair in CITY_EDGES:
		graph.add_edge(_cities_grid[pair[0]], _cities_grid[pair[1]])

	var pathfinder := TrainPathfinder.new()
	pathfinder.setup(graph)

	var train_data: TrainData = _catalog.get_train_by_id("freight_engine")
	var train_scene := preload("res://scenes/trains/train_entity.tscn")
	var train := train_scene.instantiate() as TrainEntity
	train.setup(train_data, pathfinder)
	world.add_child(train)

	var train_cargo: TrainCargo = train.get_train_cargo()
	if train_cargo != null:
		train_cargo.setup_from_train_data(train_data, _cargo_catalog)

	var schedule := RouteSchedule.new()
	schedule.route_id = "test_route"
	schedule.origin_city_id = "patna"
	schedule.destination_city_id = "kolkata"
	schedule.cargo_id = "coal"
	schedule.loop_enabled = true
	schedule.return_empty = true

	var runner := RouteRunner.new()
	var treasury := TreasuryState.new(50000)
	runner.setup(
		schedule,
		train,
		train_data,
		graph,
		fresh_runtime["patna"],
		fresh_runtime["kolkata"],
		_city_data_by_id["patna"],
		_city_data_by_id["kolkata"],
		treasury,
		_cargo_catalog
	)
	add_child(runner)
	return runner


func _wait_for_state(runner: RouteRunner, target_state: int, timeout_sec: float) -> void:
	var elapsed := 0.0
	while runner._state != target_state and runner._state != RouteRunner.State.FAILED and elapsed < timeout_sec:
		await get_tree().create_timer(0.1).timeout
		elapsed += 0.1


func _wait_for_trips(runner: RouteRunner, target_trips: int, timeout_sec: float) -> void:
	var elapsed := 0.0
	while runner.get_stats().trips_completed < target_trips and runner._state != RouteRunner.State.FAILED and elapsed < timeout_sec:
		await get_tree().create_timer(0.1).timeout
		elapsed += 0.1


func _wait_for_trips_and_state(runner: RouteRunner, target_trips: int, target_state: int, timeout_sec: float) -> void:
	var elapsed := 0.0
	while (
		(runner.get_stats().trips_completed < target_trips or runner._state != target_state)
		and runner._state != RouteRunner.State.FAILED
		and elapsed < timeout_sec
	):
		await get_tree().create_timer(0.1).timeout
		elapsed += 0.1


func _find_profile(city_data: CityData, cargo_id: String) -> CityCargoProfileData:
	for profile in city_data.cargo_profiles:
		if profile != null and profile.cargo_id == cargo_id:
			return profile
	return null


# ============================================================================
# Report
# ============================================================================

func _print_report() -> void:
	print("")
	print("========================================")
	print("SPRINT 08/09/10 ACCEPTANCE REPORT")
	print("========================================")
	print("")
	print("Clock advances days:        %s" % str(_results.get("clock_advances", false)))
	print("Production increases:       %s" % str(_results.get("production_increases", false)))
	print("Demand decreases:           %s" % str(_results.get("demand_decreases", false)))
	print("Demand not negative:        %s" % str(_results.get("demand_not_negative", false)))
	print("Stock not over max:         %s" % str(_results.get("stock_not_over_max", false)))
	print("CityData immutable:         %s" % str(_results.get("city_data_immutable", false)))
	print("Shortage price high:        %s" % str(_results.get("shortage_price_high", false)))
	print("Oversupply price low:       %s" % str(_results.get("oversupply_price_low", false)))
	print("Price clamp min:            %s" % str(_results.get("price_clamp_min", false)))
	print("Price clamp max:            %s" % str(_results.get("price_clamp_max", false)))
	print("Dynamic pre-unload price:   %s" % str(_results.get("dynamic_pre_unload", false)))
	print("Dynamic revenue:            %s" % str(_results.get("dynamic_revenue", false)))
	print("Treasury increases:         %s" % str(_results.get("treasury_increases", false)))
	print("Maintenance deducted:       %s" % str(_results.get("maintenance_deducted", false)))
	print("Treasury not negative:      %s" % str(_results.get("treasury_not_negative", false)))
	print("Missing cargo zero:         %s" % str(_results.get("missing_cargo_zero", false)))
	print("Route loads/moves/unloads:  %s" % str(_results.get("route_loads_moves_unloads", false)))
	print("Route records stats:        %s" % str(_results.get("route_records_stats", false)))
	print("Route returns to origin:    %s" % str(_results.get("route_returns", false)))
	print("Three trips completed:      %s" % str(_results.get("three_trips", false)))
	print("Empty origin retries:       %s" % str(_results.get("empty_origin_retries", false)))
	print("No path fails:              %s" % str(_results.get("no_path_fails", false)))
	print("No scope creep:             %s" % str(_results.get("no_scope_creep", false)))
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
		print("ALL CHECKS PASSED — Sprint 08/09/10 complete")
	else:
		print("SOME CHECKS FAILED — Sprint 08/09/10 incomplete")

	print("")
	print("========================================")
	get_tree().quit()
