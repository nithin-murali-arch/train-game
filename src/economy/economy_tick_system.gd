class_name EconomyTickSystem
extends Node


var _city_runtime_states: Dictionary = {}   # city_id -> CityRuntimeState
var _city_data_by_id: Dictionary = {}       # city_id -> CityData
var _cargo_catalog: Dictionary = {}
var _debug_print: bool = true


func setup(
	city_runtime_states: Dictionary,
	city_data_by_id: Dictionary,
	cargo_catalog: Dictionary
) -> void:
	_city_runtime_states = city_runtime_states
	_city_data_by_id = city_data_by_id
	_cargo_catalog = cargo_catalog


func tick_day(_day: int = 0, _month: int = 0, _year: int = 0) -> void:
	for city_id in _city_runtime_states.keys():
		var runtime: CityRuntimeState = _city_runtime_states[city_id]
		var city_data: CityData = _city_data_by_id.get(city_id, null) as CityData
		if runtime != null and city_data != null:
			_tick_city(runtime, city_data)


func _tick_city(runtime: CityRuntimeState, city_data: CityData) -> void:
	# 1. Production adds cargo
	for profile in city_data.cargo_profiles:
		if profile == null or not profile.is_enabled:
			continue
		if profile.production_per_day > 0:
			var before := runtime.get_quantity(profile.cargo_id)
			var added := runtime.add_cargo(profile.cargo_id, profile.production_per_day)
			# Clamp to max_stock
			var current := runtime.get_quantity(profile.cargo_id)
			if current > profile.max_stock:
				runtime.remove_cargo(profile.cargo_id, current - profile.max_stock)
				current = profile.max_stock

	# 2. Demand consumes cargo
	for profile in city_data.cargo_profiles:
		if profile == null or not profile.is_enabled:
			continue
		if profile.demand_per_day > 0:
			var current := runtime.get_quantity(profile.cargo_id)
			var to_consume := mini(current, profile.demand_per_day)
			if to_consume > 0:
				runtime.remove_cargo(profile.cargo_id, to_consume)

	# 3. Debug print changes
	if _debug_print:
		for profile in city_data.cargo_profiles:
			if profile == null or not profile.is_enabled:
				continue
			var qty := runtime.get_quantity(profile.cargo_id)
			print("  %s %s: %d" % [city_data.display_name, profile.cargo_id, qty])
