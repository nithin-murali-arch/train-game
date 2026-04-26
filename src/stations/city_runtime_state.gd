class_name CityRuntimeState
extends RefCounted


var city_id: String = ""
var display_name: String = ""
var grid_coord: Vector2i = Vector2i.ZERO
var inventory: CargoInventory


func setup_from_city_data(city_data: CityData, cargo_catalog: Dictionary = {}) -> void:
	city_id = city_data.city_id
	display_name = city_data.display_name
	grid_coord = city_data.map_position
	inventory = CargoInventory.new()
	# No capacity limit for city inventories in this sprint
	inventory.set_capacity_tons(999999)

	for profile in city_data.cargo_profiles:
		if profile == null:
			continue
		if profile.starting_stock > 0:
			inventory.add_cargo(profile.cargo_id, profile.starting_stock, cargo_catalog)


func get_quantity(cargo_id: String) -> int:
	if inventory == null:
		return 0
	return inventory.get_quantity(cargo_id)


## Returns amount actually added
func add_cargo(cargo_id: String, quantity: int) -> int:
	if inventory == null:
		return 0
	return inventory.add_cargo(cargo_id, quantity)


## Returns amount actually removed
func remove_cargo(cargo_id: String, quantity: int) -> int:
	if inventory == null:
		return 0
	return inventory.remove_cargo(cargo_id, quantity)


func validate(cargo_catalog: Dictionary = {}) -> Array[String]:
	var errors: Array[String] = []

	if city_id.strip_edges().is_empty():
		errors.append("city_id is required")

	if display_name.strip_edges().is_empty():
		errors.append("display_name is required")

	if inventory != null:
		var inv_errors := inventory.validate(cargo_catalog)
		for err in inv_errors:
			errors.append("inventory: " + err)

	return errors
