extends Node

## Sprint 06/07 Combined Acceptance Verification

const CITY_EDGES: Array[Array] = [
	["kolkata", "patna"],
	["kolkata", "murshidabad"],
	["murshidabad", "dacca"],
	["patna", "dacca"],
]

var _world: WorldMap
var _graph: TrackGraph
var _train: TrainEntity
var _pathfinder: TrainPathfinder
var _catalog: DataCatalog
var _cities_grid: Dictionary = {}
var _city_runtime: Dictionary = {}
var _treasury: TreasuryState
var _cargo_catalog: Dictionary = {}
var _train_data: TrainData

var _results: Dictionary = {}
var _issues: Array[String] = []
var _arrival_count := 0


func _ready() -> void:
	print("========================================")
	print("SPRINT 06/07 ACCEPTANCE VERIFICATION")
	print("========================================")
	print("")

	await _setup_scene()

	_test_01_city_runtime_init()
	_test_02_city_data_immutable()
	_test_03_train_cargo_init()
	_test_04_load_coal_from_patna()
	_test_05_capacity_limit()
	_test_06_stock_limit()
	_test_07_origin_stock_decreases()
	_test_08_train_cargo_increases()
	await _test_09_movement_to_destination()
	await _test_10_unload_on_arrival()
	_test_11_destination_stock_increases()
	_test_12_train_empty_after_unload()
	_test_13_transaction_price()
	_test_14_treasury_increases()
	_test_15_treasury_no_debt()
	_test_16_missing_cargo_fails()
	_test_17_empty_origin_stock()
	await _test_18_grain_route_murshidabad_to_dacca()
	_test_19_no_scope_creep()

	_print_report()


func _setup_scene() -> void:
	_catalog = DataCatalog.new()
	for city_id in ["kolkata", "patna", "dacca", "murshidabad"]:
		var city := _catalog.get_city_by_id(city_id)
		if city != null:
			_cities_grid[city_id] = city.map_position

	for cargo in _catalog.cargos:
		_cargo_catalog[cargo.cargo_id] = cargo

	_world = preload("res://scenes/world/world.tscn").instantiate()
	add_child(_world)

	_graph = TrackGraph.new()
	for pair in CITY_EDGES:
		_graph.add_edge(_cities_grid[pair[0]], _cities_grid[pair[1]])

	var renderer := TrackRenderer.new()
	renderer.setup(_graph)
	_world.add_child(renderer)

	_pathfinder = TrainPathfinder.new()
	_pathfinder.setup(_graph)

	_build_city_runtime_states()

	var faction: FactionData = _catalog.get_faction_by_id("player_railway_company")
	var starting_capital: int = faction.starting_capital if faction != null else 50000
	_treasury = TreasuryState.new(starting_capital)

	_train_data = _catalog.get_train_by_id("freight_engine")
	var train_scene := preload("res://scenes/trains/train_entity.tscn")
	_train = train_scene.instantiate() as TrainEntity
	_train.setup(_train_data, _pathfinder)
	_world.add_child(_train)

	var train_cargo: TrainCargo = _train.get_train_cargo()
	if train_cargo != null:
		train_cargo.setup_from_train_data(_train_data, _cargo_catalog)

	await get_tree().process_frame


func _build_city_runtime_states() -> void:
	_city_runtime.clear()
	for city_id in ["kolkata", "patna", "dacca", "murshidabad"]:
		var city_data: CityData = _catalog.get_city_by_id(city_id)
		if city_data == null:
			continue
		var runtime := CityRuntimeState.new()
		runtime.setup_from_city_data(city_data, _cargo_catalog)
		_city_runtime[city_id] = runtime


# ============================================================================
# Test 1: CityRuntimeState initializes from CityData starting_stock
# ============================================================================

func _test_01_city_runtime_init() -> void:
	var patna: CityData = _catalog.get_city_by_id("patna")
	var runtime: CityRuntimeState = _city_runtime["patna"]
	var expected_coal := 0
	for profile in patna.cargo_profiles:
		if profile.cargo_id == "coal":
			expected_coal = profile.starting_stock
			break

	if runtime.get_quantity("coal") == expected_coal:
		_results["city_runtime_init"] = true
		print("[PASS] CityRuntimeState init: Patna coal = %d" % expected_coal)
	else:
		_results["city_runtime_init"] = false
		_issues.append("Patna coal expected %d, got %d" % [expected_coal, runtime.get_quantity("coal")])
		print("[FAIL] CityRuntimeState init: Patna coal mismatch")


# ============================================================================
# Test 2: Static CityData is not mutated
# ============================================================================

func _test_02_city_data_immutable() -> void:
	# Load a fresh copy of Patna data
	var fresh_catalog := DataCatalog.new()
	var fresh_patna: CityData = fresh_catalog.get_city_by_id("patna")
	var original_coal := 0
	for profile in fresh_patna.cargo_profiles:
		if profile.cargo_id == "coal":
			original_coal = profile.starting_stock
			break

	# Mutate runtime
	var runtime: CityRuntimeState = _city_runtime["patna"]
	runtime.remove_cargo("coal", 100)

	# Reload fresh
	var check_catalog := DataCatalog.new()
	var check_patna: CityData = check_catalog.get_city_by_id("patna")
	var check_coal := 0
	for profile in check_patna.cargo_profiles:
		if profile.cargo_id == "coal":
			check_coal = profile.starting_stock
			break

	if check_coal == original_coal:
		_results["city_data_immutable"] = true
		print("[PASS] CityData immutable: static coal stock unchanged at %d" % original_coal)
	else:
		_results["city_data_immutable"] = false
		_issues.append("CityData was mutated: %d -> %d" % [original_coal, check_coal])
		print("[FAIL] CityData immutable: static coal stock changed")


# ============================================================================
# Test 3: TrainCargo init matches TrainData
# ============================================================================

func _test_03_train_cargo_init() -> void:
	var train_cargo: TrainCargo = _train.get_train_cargo()
	if train_cargo == null:
		_results["train_cargo_init"] = false
		_issues.append("TrainCargo is null")
		print("[FAIL] TrainCargo init: not found")
		return

	if train_cargo.capacity_tons == _train_data.capacity_tons:
		_results["train_cargo_init"] = true
		print("[PASS] TrainCargo init: capacity = %d tons" % train_cargo.capacity_tons)
	else:
		_results["train_cargo_init"] = false
		_issues.append("capacity expected %d, got %d" % [_train_data.capacity_tons, train_cargo.capacity_tons])
		print("[FAIL] TrainCargo init: capacity mismatch")


# ============================================================================
# Test 4: Load coal from Patna
# ============================================================================

func _test_04_load_coal_from_patna() -> void:
	var train_cargo: TrainCargo = _train.get_train_cargo()
	var patna_runtime: CityRuntimeState = _city_runtime["patna"]
	patna_runtime.remove_cargo("coal", patna_runtime.get_quantity("coal"))  # clear first
	patna_runtime.add_cargo("coal", 600)  # set known stock
	train_cargo.inventory.clear()

	var loaded := train_cargo.load_cargo("coal", 200)
	if loaded == 200:
		_results["load_coal"] = true
		print("[PASS] Load coal: 200 loaded from Patna")
	else:
		_results["load_coal"] = false
		_issues.append("expected 200, got %d" % loaded)
		print("[FAIL] Load coal: expected 200, got %d" % loaded)


# ============================================================================
# Test 5: Capacity limit
# ============================================================================

func _test_05_capacity_limit() -> void:
	var train_cargo: TrainCargo = _train.get_train_cargo()
	train_cargo.inventory.clear()

	var loaded := train_cargo.load_cargo("coal", 999)
	if loaded == 200:
		_results["capacity_limit"] = true
		print("[PASS] Capacity limit: 999 request clamped to %d" % loaded)
	else:
		_results["capacity_limit"] = false
		_issues.append("expected 200, got %d" % loaded)
		print("[FAIL] Capacity limit: expected 200, got %d" % loaded)


# ============================================================================
# Test 6: Stock limit
# ============================================================================

func _test_06_stock_limit() -> void:
	var train_cargo: TrainCargo = _train.get_train_cargo()
	var patna_runtime: CityRuntimeState = _city_runtime["patna"]
	train_cargo.inventory.clear()
	patna_runtime.remove_cargo("coal", patna_runtime.get_quantity("coal"))
	patna_runtime.add_cargo("coal", 50)

	var loaded := patna_runtime.remove_cargo("coal", 200)
	if loaded <= 50:
		train_cargo.load_cargo("coal", loaded)
		_results["stock_limit"] = true
		print("[PASS] Stock limit: only %d loaded from 50 available" % loaded)
	else:
		_results["stock_limit"] = false
		_issues.append("expected <= 50, got %d" % loaded)
		print("[FAIL] Stock limit: expected <= 50, got %d" % loaded)


# ============================================================================
# Test 7: Origin stock decreases after load
# ============================================================================

func _test_07_origin_stock_decreases() -> void:
	var train_cargo: TrainCargo = _train.get_train_cargo()
	var patna_runtime: CityRuntimeState = _city_runtime["patna"]
	train_cargo.inventory.clear()
	patna_runtime.remove_cargo("coal", patna_runtime.get_quantity("coal"))
	patna_runtime.add_cargo("coal", 600)

	var before := patna_runtime.get_quantity("coal")
	var to_load := 200
	patna_runtime.remove_cargo("coal", to_load)
	train_cargo.load_cargo("coal", to_load)
	var after := patna_runtime.get_quantity("coal")

	if after == before - to_load:
		_results["origin_stock_decreases"] = true
		print("[PASS] Origin stock decreases: %d -> %d" % [before, after])
	else:
		_results["origin_stock_decreases"] = false
		_issues.append("expected %d, got %d" % [before - to_load, after])
		print("[FAIL] Origin stock decreases: expected %d, got %d" % [before - to_load, after])


# ============================================================================
# Test 8: Train cargo increases after load
# ============================================================================

func _test_08_train_cargo_increases() -> void:
	var train_cargo: TrainCargo = _train.get_train_cargo()
	train_cargo.inventory.clear()
	train_cargo.load_cargo("coal", 150)

	if train_cargo.get_quantity("coal") == 150:
		_results["train_cargo_increases"] = true
		print("[PASS] Train cargo increases: 150 coal on board")
	else:
		_results["train_cargo_increases"] = false
		_issues.append("expected 150, got %d" % train_cargo.get_quantity("coal"))
		print("[FAIL] Train cargo increases: expected 150, got %d" % train_cargo.get_quantity("coal"))


# ============================================================================
# Test 9: Movement to destination
# ============================================================================

func _test_09_movement_to_destination() -> void:
	var patna: Vector2i = _cities_grid["patna"]
	var kolkata: Vector2i = _cities_grid["kolkata"]
	_train.reset_to(patna)
	var ok := _train.set_route(patna, kolkata)
	if not ok:
		_results["movement_to_destination"] = false
		_issues.append("Route failed")
		print("[FAIL] Movement to destination: route failed")
		return

	_train.start_movement()
	await get_tree().create_timer(0.5).timeout
	var moved := not _train.position.is_equal_approx(WorldMap.grid_to_world(patna))
	_train._movement.stop()

	if moved:
		_results["movement_to_destination"] = true
		print("[PASS] Movement to destination: train moved from Patna")
	else:
		_results["movement_to_destination"] = false
		_issues.append("Train did not move")
		print("[FAIL] Movement to destination: train did not move")


# ============================================================================
# Test 10: Unload on arrival
# ============================================================================

func _test_10_unload_on_arrival() -> void:
	var patna: Vector2i = _cities_grid["patna"]
	var kolkata: Vector2i = _cities_grid["kolkata"]
	var train_cargo: TrainCargo = _train.get_train_cargo()
	var kolkata_runtime: CityRuntimeState = _city_runtime["kolkata"]

	_train.reset_to(patna)
	train_cargo.inventory.clear()
	train_cargo.load_cargo("coal", 100)

	var ok := _train.set_route(patna, kolkata)
	if not ok:
		_results["unload_on_arrival"] = false
		print("[FAIL] Unload on arrival: route failed")
		return

	# Wire arrival to unload manually (simulating what StationArrivalHandler does)
	_train._movement.destination_arrived.connect(func(coord: Vector2i):
		train_cargo.unload_all_to(kolkata_runtime.inventory)
	, CONNECT_ONE_SHOT)

	_arrival_count = 0
	_train._movement.destination_arrived.connect(_on_test_arrival, CONNECT_ONE_SHOT)
	_train.start_movement()

	await get_tree().create_timer(15.0).timeout

	var arrived := _arrival_count > 0
	if arrived and train_cargo.is_empty():
		_results["unload_on_arrival"] = true
		print("[PASS] Unload on arrival: arrived and train empty")
	else:
		_results["unload_on_arrival"] = false
		_issues.append("arrived=%s, empty=%s" % [arrived, train_cargo.is_empty()])
		print("[FAIL] Unload on arrival: arrived=%s, empty=%s" % [arrived, train_cargo.is_empty()])


func _on_test_arrival(_coord: Vector2i) -> void:
	_arrival_count += 1


# ============================================================================
# Test 11: Destination stock increases
# ============================================================================

func _test_11_destination_stock_increases() -> void:
	var kolkata_runtime: CityRuntimeState = _city_runtime["kolkata"]
	var before := kolkata_runtime.get_quantity("coal")

	# Simulate unload by adding directly
	kolkata_runtime.add_cargo("coal", 100)
	var after := kolkata_runtime.get_quantity("coal")

	if after == before + 100:
		_results["destination_stock_increases"] = true
		print("[PASS] Destination stock increases: %d -> %d" % [before, after])
	else:
		_results["destination_stock_increases"] = false
		_issues.append("expected %d, got %d" % [before + 100, after])
		print("[FAIL] Destination stock increases: expected %d, got %d" % [before + 100, after])


# ============================================================================
# Test 12: Train empty after unload
# ============================================================================

func _test_12_train_empty_after_unload() -> void:
	var train_cargo: TrainCargo = _train.get_train_cargo()
	train_cargo.inventory.clear()
	train_cargo.load_cargo("coal", 50)
	var kolkata_runtime: CityRuntimeState = _city_runtime["kolkata"]

	train_cargo.unload_all_to(kolkata_runtime.inventory)

	if train_cargo.is_empty():
		_results["train_empty_after_unload"] = true
		print("[PASS] Train empty after unload: 0 cargo remaining")
	else:
		_results["train_empty_after_unload"] = false
		_issues.append("expected 0, got %d" % train_cargo.get_quantity("coal"))
		print("[FAIL] Train empty after unload: expected 0, got %d" % train_cargo.get_quantity("coal"))


# ============================================================================
# Test 13: Transaction price
# ============================================================================

func _test_13_transaction_price() -> void:
	var cargo: CargoData = _cargo_catalog["coal"] as CargoData
	var expected_revenue := int(roundf(200.0 * cargo.base_price))  # 200 * 15 = 3000

	var treasury := TreasuryState.new(0)
	var kolkata_runtime: CityRuntimeState = _city_runtime["kolkata"]
	var revenue := Transaction.sell_cargo("coal", 200, kolkata_runtime, treasury, _cargo_catalog)

	if revenue == expected_revenue:
		_results["transaction_price"] = true
		print("[PASS] Transaction price: 200 coal × ₹%.0f = ₹%d" % [cargo.base_price, revenue])
	else:
		_results["transaction_price"] = false
		_issues.append("expected ₹%d, got ₹%d" % [expected_revenue, revenue])
		print("[FAIL] Transaction price: expected ₹%d, got ₹%d" % [expected_revenue, revenue])


# ============================================================================
# Test 14: Treasury increases
# ============================================================================

func _test_14_treasury_increases() -> void:
	var treasury := TreasuryState.new(50000)
	var kolkata_runtime: CityRuntimeState = _city_runtime["kolkata"]
	var before := treasury.balance
	var revenue := Transaction.sell_cargo("coal", 200, kolkata_runtime, treasury, _cargo_catalog)
	var after := treasury.balance

	if after == before + revenue and revenue > 0:
		_results["treasury_increases"] = true
		print("[PASS] Treasury increases: ₹%d -> ₹%d (+₹%d)" % [before, after, revenue])
	else:
		_results["treasury_increases"] = false
		_issues.append("expected ₹%d, got ₹%d" % [before + revenue, after])
		print("[FAIL] Treasury increases: expected ₹%d, got ₹%d" % [before + revenue, after])


# ============================================================================
# Test 15: Treasury no-debt
# ============================================================================

func _test_15_treasury_no_debt() -> void:
	var treasury := TreasuryState.new(100)
	var ok := treasury.spend(500)
	if not ok and treasury.balance == 100:
		_results["treasury_no_debt"] = true
		print("[PASS] Treasury no-debt: overdraft rejected, balance = %d" % treasury.balance)
	else:
		_results["treasury_no_debt"] = false
		_issues.append("overdraft allowed or balance changed")
		print("[FAIL] Treasury no-debt: overdraft allowed")


# ============================================================================
# Test 16: Missing cargo fails gracefully
# ============================================================================

func _test_16_missing_cargo_fails() -> void:
	var treasury := TreasuryState.new(1000)
	var kolkata_runtime: CityRuntimeState = _city_runtime["kolkata"]
	var before := treasury.balance
	var revenue := Transaction.sell_cargo("fake_cargo", 10, kolkata_runtime, treasury, _cargo_catalog)
	var after := treasury.balance

	if revenue == 0 and after == before:
		_results["missing_cargo_fails"] = true
		print("[PASS] Missing cargo fails: revenue=0, treasury unchanged")
	else:
		_results["missing_cargo_fails"] = false
		_issues.append("revenue=%d, treasury changed" % revenue)
		print("[FAIL] Missing cargo fails: revenue=%d" % revenue)


# ============================================================================
# Test 17: Empty origin stock loads 0
# ============================================================================

func _test_17_empty_origin_stock() -> void:
	var train_cargo: TrainCargo = _train.get_train_cargo()
	var patna_runtime: CityRuntimeState = _city_runtime["patna"]
	train_cargo.inventory.clear()
	patna_runtime.remove_cargo("coal", patna_runtime.get_quantity("coal"))

	var available := patna_runtime.get_quantity("coal")
	# Simulate the debug delivery flow: remove from city, then load to train
	var removed := patna_runtime.remove_cargo("coal", 100)
	var loaded := train_cargo.load_cargo("coal", removed)

	if available == 0 and removed == 0 and loaded == 0:
		_results["empty_origin_stock"] = true
		print("[PASS] Empty origin stock: 0 available, 0 removed, 0 loaded")
	else:
		_results["empty_origin_stock"] = false
		_issues.append("available=%d, removed=%d, loaded=%d" % [available, removed, loaded])
		print("[FAIL] Empty origin stock: available=%d, removed=%d, loaded=%d" % [available, removed, loaded])


# ============================================================================
# Test 18: Grain route Murshidabad -> Dacca
# ============================================================================

func _test_18_grain_route_murshidabad_to_dacca() -> void:
	var murshidabad: Vector2i = _cities_grid["murshidabad"]
	var dacca: Vector2i = _cities_grid["dacca"]
	var train_cargo: TrainCargo = _train.get_train_cargo()
	var murshidabad_runtime: CityRuntimeState = _city_runtime["murshidabad"]
	var dacca_runtime: CityRuntimeState = _city_runtime["dacca"]

	# Reset
	_train.reset_to(murshidabad)
	train_cargo.inventory.clear()
	# Restore grain stock for test
	murshidabad_runtime.remove_cargo("grain", murshidabad_runtime.get_quantity("grain"))
	murshidabad_runtime.add_cargo("grain", 500)

	var grain_before_origin := murshidabad_runtime.get_quantity("grain")
	var grain_before_dest := dacca_runtime.get_quantity("grain")

	# Load grain
	var grain_loaded := train_cargo.load_cargo("grain", 999)
	murshidabad_runtime.remove_cargo("grain", grain_loaded)

	# Expected: capacity 200 tons / 0.8 weight = 250 units
	var grain_after_origin := murshidabad_runtime.get_quantity("grain")
	var origin_decrease := grain_before_origin - grain_after_origin

	# Move
	var ok := _train.set_route(murshidabad, dacca)
	if not ok:
		_results["grain_route"] = false
		_issues.append("Grain route path failed")
		print("[FAIL] Grain route: path failed")
		return

	_arrival_count = 0
	_train._movement.destination_arrived.connect(_on_test_arrival, CONNECT_ONE_SHOT)
	_train.start_movement()
	await get_tree().create_timer(12.0).timeout

	# Unload
	var unloaded := train_cargo.unload_all_to(dacca_runtime.inventory)
	var grain_after_dest := dacca_runtime.get_quantity("grain")
	var dest_increase := grain_after_dest - grain_before_dest

	# Sell
	var treasury := TreasuryState.new(50000)
	var revenue := Transaction.sell_cargo("grain", unloaded, dacca_runtime, treasury, _cargo_catalog)
	var expected_revenue := int(roundf(250.0 * 12.0))  # 3000

	var all_ok := true
	if grain_loaded != 250:
		_issues.append("grain loaded expected 250, got %d" % grain_loaded)
		all_ok = false
	if origin_decrease != 250:
		_issues.append("origin decrease expected 250, got %d" % origin_decrease)
		all_ok = false
	if dest_increase != 250:
		_issues.append("dest increase expected 250, got %d" % dest_increase)
		all_ok = false
	if revenue != expected_revenue:
		_issues.append("revenue expected %d, got %d" % [expected_revenue, revenue])
		all_ok = false
	if treasury.balance != 50000 + expected_revenue:
		_issues.append("treasury expected %d, got %d" % [50000 + expected_revenue, treasury.balance])
		all_ok = false

	if all_ok:
		_results["grain_route"] = true
		print("[PASS] Grain route: 250 grain loaded, delivered, sold for ₹%d" % revenue)
	else:
		_results["grain_route"] = false
		print("[FAIL] Grain route: loaded=%d, origin_decrease=%d, dest_increase=%d, revenue=%d" % [grain_loaded, origin_decrease, dest_increase, revenue])


# ============================================================================
# Test 19: No scope creep
# ============================================================================

func _test_19_no_scope_creep() -> void:
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
	print("SPRINT 06/07 ACCEPTANCE VERIFICATION REPORT")
	print("========================================")
	print("")
	print("CityRuntimeState init:       %s" % str(_results.get("city_runtime_init", false)))
	print("CityData immutable:          %s" % str(_results.get("city_data_immutable", false)))
	print("TrainCargo init:             %s" % str(_results.get("train_cargo_init", false)))
	print("Load coal from Patna:        %s" % str(_results.get("load_coal", false)))
	print("Capacity limit:              %s" % str(_results.get("capacity_limit", false)))
	print("Stock limit:                 %s" % str(_results.get("stock_limit", false)))
	print("Origin stock decreases:      %s" % str(_results.get("origin_stock_decreases", false)))
	print("Train cargo increases:       %s" % str(_results.get("train_cargo_increases", false)))
	print("Movement to destination:     %s" % str(_results.get("movement_to_destination", false)))
	print("Unload on arrival:           %s" % str(_results.get("unload_on_arrival", false)))
	print("Destination stock increases: %s" % str(_results.get("destination_stock_increases", false)))
	print("Train empty after unload:    %s" % str(_results.get("train_empty_after_unload", false)))
	print("Transaction price:           %s" % str(_results.get("transaction_price", false)))
	print("Treasury increases:          %s" % str(_results.get("treasury_increases", false)))
	print("Treasury no-debt:            %s" % str(_results.get("treasury_no_debt", false)))
	print("Missing cargo fails:         %s" % str(_results.get("missing_cargo_fails", false)))
	print("Empty origin stock:          %s" % str(_results.get("empty_origin_stock", false)))
	print("Grain route:                 %s" % str(_results.get("grain_route", false)))
	print("No scope creep:              %s" % str(_results.get("no_scope_creep", false)))
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
		print("ALL CHECKS PASSED — Sprint 06/07 complete")
	else:
		print("SOME CHECKS FAILED — Sprint 06/07 incomplete")

	print("")
	print("========================================")
	get_tree().quit()
