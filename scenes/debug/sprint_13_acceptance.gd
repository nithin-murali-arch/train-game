extends Node


var _route_toy: RouteToyPlayable


func _ready() -> void:
	print("=== SPRINT 13 ACCEPTANCE TEST ===")
	
	# Wait a frame for RouteToyPlayable to initialize
	await get_tree().process_frame
	
	_route_toy = $RouteToyPlayable as RouteToyPlayable
	if _route_toy == null:
		push_error("RouteToyPlayable not found")
		return
	
	# Wait another frame for full setup
	await get_tree().process_frame
	
	_test_1_empty_start()
	_test_2_build_track()
	_test_3_buy_train()
	_test_4_create_route()
	_test_5_save_load()
	_test_6_reset()
	_test_7_hud_panels()
	_test_8_v1_backward_compat()
	
	print("\n=== ALL TESTS PASSED ===")
	get_tree().quit()


func _test_1_empty_start() -> void:
	print("\n[TEST 1] Empty start state")
	
	assert(_route_toy.owned_trains.is_empty(), "Should have no trains")
	assert(_route_toy.active_runners.is_empty(), "Should have no routes")
	assert(_route_toy.graph.get_edge_count() == 0, "Should have no track edges")
	assert(_route_toy.clock.is_paused, "Clock should be paused")
	assert(_route_toy.get_treasury_balance() == 50000, "Treasury should be 50000")
	assert(_route_toy.get_runner_state_name() == "No route", "Runner state should be 'No route'")
	assert(_route_toy.get_runner_stats() == null, "Runner stats should be null")
	
	print("  PASS: Empty start state verified")


func _test_2_build_track() -> void:
	print("\n[TEST 2] Build track")
	
	var initial_balance := _route_toy.get_treasury_balance()
	var patna_grid: Vector2i = _route_toy.cities_grid["patna"]
	var kolkata_grid: Vector2i = _route_toy.cities_grid["kolkata"]
	
	# Manually add edge (simulating TrackPlacer behavior)
	var added := _route_toy.graph.add_edge(patna_grid, kolkata_grid)
	assert(added, "Should add Patna-Kolkata edge")
	
	# In real gameplay, TrackPlacer would charge treasury. Simulate that:
	var length_km := patna_grid.distance_to(kolkata_grid)
	var cost := int(roundf(length_km * 500.0))
	_route_toy.treasury.spend(cost)
	
	assert(_route_toy.graph.get_edge_count() == 1, "Should have 1 edge")
	assert(_route_toy.get_treasury_balance() == initial_balance - cost, "Treasury should decrease by track cost")
	
	print("  PASS: Track built, cost = ₹%d" % cost)


func _test_3_buy_train() -> void:
	print("\n[TEST 3] Buy train")
	
	var initial_balance := _route_toy.get_treasury_balance()
	var ok := _route_toy.purchase_train("freight_engine", "patna")
	assert(ok, "Should purchase freight engine")
	assert(_route_toy.owned_trains.size() == 1, "Should have 1 train")
	assert(_route_toy.get_treasury_balance() == initial_balance - 5000, "Treasury should decrease by 5000")
	
	# Verify train catalog
	var catalog := _route_toy.get_train_catalog()
	assert(catalog.has("freight_engine"), "Catalog should have freight_engine")
	assert(catalog.has("mixed_engine"), "Catalog should have mixed_engine")
	
	# Try buying unaffordable
	_route_toy.treasury.balance = 1000
	var ok2 := _route_toy.purchase_train("mixed_engine", "kolkata")
	assert(not ok2, "Should fail to buy mixed engine with insufficient funds")
	
	# Restore balance for next tests
	_route_toy.treasury.balance = initial_balance - 5000
	
	print("  PASS: Train purchased")


func _test_4_create_route() -> void:
	print("\n[TEST 4] Create route")
	
	var params := {
		"train_index": 0,
		"origin_city_id": "patna",
		"destination_city_id": "kolkata",
		"cargo_id": "coal",
		"loop_enabled": true,
		"return_empty": true,
	}
	
	var ok := _route_toy.create_route(params)
	assert(ok, "Should create route")
	assert(_route_toy.active_runners.size() == 1, "Should have 1 runner")
	assert(not _route_toy.clock.is_paused, "Clock should auto-resume on route start")
	
	# Verify runner is in a non-IDLE state
	var state := _route_toy.get_runner_state_name()
	assert(state != "IDLE" and state != "No route", "Runner should be active")
	
	print("  PASS: Route created and started")


func _test_5_save_load() -> void:
	print("\n[TEST 5] Save and load")
	
	# Save
	var save_ok := _route_toy.save_game()
	assert(save_ok, "Should save successfully")
	
	# Remember state
	var old_train_count := _route_toy.owned_trains.size()
	var old_runner_count := _route_toy.active_runners.size()
	var old_edge_count := _route_toy.graph.get_edge_count()
	var old_balance := _route_toy.get_treasury_balance()
	
	# Reset
	_route_toy.reset_simulation()
	assert(_route_toy.owned_trains.is_empty(), "Should have no trains after reset")
	assert(_route_toy.active_runners.is_empty(), "Should have no routes after reset")
	assert(_route_toy.graph.get_edge_count() == 0, "Should have no edges after reset")
	
	# Load
	var load_ok := _route_toy.load_game()
	assert(load_ok, "Should load successfully")
	assert(_route_toy.owned_trains.size() == old_train_count, "Should restore trains")
	assert(_route_toy.active_runners.size() == old_runner_count, "Should restore runners")
	assert(_route_toy.graph.get_edge_count() == old_edge_count, "Should restore edges")
	assert(_route_toy.get_treasury_balance() == old_balance, "Should restore treasury")
	
	print("  PASS: Save/load cycle works")


func _test_6_reset() -> void:
	print("\n[TEST 6] Reset")
	
	_route_toy.reset_simulation()
	assert(_route_toy.owned_trains.is_empty(), "Should have no trains")
	assert(_route_toy.active_runners.is_empty(), "Should have no routes")
	assert(_route_toy.graph.get_edge_count() == 0, "Should have no edges")
	assert(_route_toy.clock.is_paused, "Clock should be paused")
	assert(_route_toy.get_treasury_balance() == 50000, "Treasury should be reset to 50000")
	
	print("  PASS: Reset works correctly")


func _test_7_hud_panels() -> void:
	print("\n[TEST 7] HUD panel queries")
	
	# Verify catalog and display name queries work
	var train_names := _route_toy.get_train_display_names()
	assert(train_names.is_empty(), "Should have no train names when no trains")
	
	var city_names := _route_toy.get_city_display_names()
	assert(city_names.size() == 4, "Should have 4 cities")
	
	var cargo_ids := _route_toy.get_cargo_ids()
	assert(cargo_ids.size() >= 3, "Should have at least 3 cargo types")
	
	# Buy a train and verify names update
	_route_toy.purchase_train("freight_engine", "patna")
	train_names = _route_toy.get_train_display_names()
	assert(train_names.size() == 1, "Should have 1 train name")
	assert(train_names[0] == "Freight Engine", "Should be Freight Engine")
	
	# Path estimate without track
	var est := _route_toy.get_path_estimate("patna", "kolkata")
	assert(not est.valid, "Should be invalid without track")
	
	# Build track and verify estimate
	var patna_grid: Vector2i = _route_toy.cities_grid["patna"]
	var kolkata_grid: Vector2i = _route_toy.cities_grid["kolkata"]
	_route_toy.graph.add_edge(patna_grid, kolkata_grid)
	est = _route_toy.get_path_estimate("patna", "kolkata")
	assert(est.valid, "Should be valid with track")
	assert(est.distance_km > 0, "Distance should be positive")
	
	print("  PASS: HUD panel queries work")


func _test_8_v1_backward_compat() -> void:
	print("\n[TEST 8] v1 save backward compatibility")
	
	# Build a v1-style save manually
	var v1_json := JSON.stringify({
		"save_version": 1,
		"saved_at": "2026-04-26T10:00:00",
		"clock": {
			"current_day": 5,
			"current_month": 2,
			"current_year": 1857,
			"is_paused": true,
			"days_per_real_second": 2.0,
		},
		"treasury": {"balance": 42000},
		"cities": {
			"patna": {"coal": 500},
			"kolkata": {"coal": 50},
		},
		"track_graph": {
			"nodes": [{"x": 36, "y": 18}, {"x": 10, "y": 10}],
			"edges": [
				{
					"from": {"x": 36, "y": 18},
					"to": {"x": 10, "y": 10},
					"owner_faction_id": "player_railway_company",
					"condition": 1.0,
					"toll_per_km": 0.0,
					"access_mode": "private",
					"is_blocked": false,
				}
			]
		},
		"train": {
			"train_id": "freight_engine",
			"grid_coord": {"x": 36, "y": 18},
			"cargo": {}
		},
		"route": {
			"schedule": {
				"route_id": "patna_to_kolkata_coal",
				"origin_city_id": "patna",
				"destination_city_id": "kolkata",
				"cargo_id": "coal",
				"loop_enabled": true,
				"return_empty": true,
			},
			"stats": {
				"route_id": "patna_to_kolkata_coal",
				"trips_completed": 3,
				"total_revenue": 1500,
				"total_operating_cost": 150,
				"total_profit": 1350,
				"total_cargo_delivered": 100,
				"last_trip_revenue": 500,
				"last_trip_operating_cost": 50,
				"last_trip_profit": 450,
			},
			"runner_state": "IDLE"
		}
	})
	
	# Write v1 save file
	var path := "user://saves/route_toy_save.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(v1_json)
	file.close()
	
	# Reset and load
	_route_toy.reset_simulation()
	var load_ok := _route_toy.load_game()
	assert(load_ok, "Should load v1 save")
	
	assert(_route_toy.owned_trains.size() == 1, "Should restore 1 train from v1")
	assert(_route_toy.active_runners.size() == 1, "Should restore 1 route from v1")
	assert(_route_toy.graph.get_edge_count() == 1, "Should restore 1 edge from v1")
	assert(_route_toy.get_treasury_balance() == 42000, "Should restore treasury from v1")
	assert(_route_toy.clock.current_day == 5, "Should restore day from v1")
	
	var stats: RouteProfitStats = _route_toy.get_runner_stats()
	assert(stats != null, "Should have stats")
	assert(stats.trips_completed == 3, "Should restore trips_completed from v1")
	assert(stats.total_revenue == 1500, "Should restore total_revenue from v1")
	
	print("  PASS: v1 backward compatibility works")
