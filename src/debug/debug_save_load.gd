extends Node


var _route_toy: RouteToyPlayable
var _phase: int = 0
var _start_time: float = 0.0
var _save_data: Dictionary = {}


func _ready() -> void:
	_start_time = Time.get_ticks_msec() / 1000.0
	print("=== DEBUG SAVE/LOAD TEST ===")
	
	# Find RouteToyPlayable in tree
	await get_tree().process_frame
	_route_toy = _find_route_toy()
	if _route_toy == null:
		print("FAIL: RouteToyPlayable not found")
		return
	
	print("Found RouteToyPlayable")
	_phase = 1


func _find_route_toy() -> RouteToyPlayable:
	var root := get_tree().current_scene
	if root == null:
		return null
	if root is RouteToyPlayable:
		return root as RouteToyPlayable
	for child in root.get_children():
		if child is RouteToyPlayable:
			return child as RouteToyPlayable
	return null


func _process(_delta: float) -> void:
	if _route_toy == null:
		return
	
	var elapsed := (Time.get_ticks_msec() / 1000.0) - _start_time
	
	match _phase:
		1:
			# Wait for first trip to complete
			if _route_toy.get_runner_stats().trips_completed >= 1:
				print("Phase 1: First trip completed")
				_record_state("after_trip_1")
				_phase = 2
		2:
			# Wait for second trip
			if _route_toy.get_runner_stats().trips_completed >= 2:
				print("Phase 2: Second trip completed")
				_record_state("after_trip_2")
				# Save
				var ok := _route_toy.save_game()
				print("Save result: %s" % ok)
				_phase = 3
		3:
			# Let one more tick pass, then load
			if elapsed > 25.0:
				print("Phase 3: Loading saved game...")
				var ok := _route_toy.load_game()
				print("Load result: %s" % ok)
				_phase = 4
		4:
			# Verify loaded state matches saved state
			await get_tree().process_frame
			_verify_loaded_state()
			print("=== SAVE/LOAD TEST COMPLETE ===")
			get_tree().quit()


func _record_state(label: String) -> void:
	var stats := _route_toy.get_runner_stats()
	var state := {
		"label": label,
		"treasury": _route_toy.get_treasury_balance(),
		"date": _route_toy.get_date_string(),
		"trips": stats.trips_completed if stats != null else 0,
		"total_profit": stats.total_profit if stats != null else 0,
		"patna_coal": _route_toy.get_city_stock("patna", "coal"),
		"kolkata_coal": _route_toy.get_city_stock("kolkata", "coal"),
	}
	_save_data[label] = state
	print("Recorded state [%s]: %s" % [label, state])


func _verify_loaded_state() -> void:
	var saved = _save_data.get("after_trip_2")
	if saved == null:
		print("FAIL: No saved state to compare against")
		return
	
	var current = {
		"treasury": _route_toy.get_treasury_balance(),
		"trips": _route_toy.get_runner_stats().trips_completed if _route_toy.get_runner_stats() != null else 0,
		"total_profit": _route_toy.get_runner_stats().total_profit if _route_toy.get_runner_stats() != null else 0,
		"patna_coal": _route_toy.get_city_stock("patna", "coal"),
		"kolkata_coal": _route_toy.get_city_stock("kolkata", "coal"),
	}
	
	print("Saved state:  %s" % saved)
	print("Loaded state: %s" % current)
	
	var ok := true
	if current.treasury != saved.treasury:
		print("FAIL: Treasury mismatch")
		ok = false
	if current.trips != saved.trips:
		print("FAIL: Trips mismatch")
		ok = false
	if current.total_profit != saved.total_profit:
		print("FAIL: Total profit mismatch")
		ok = false
	
	if ok:
		print("PASS: All loaded values match saved values")
