class_name TrainCargo
extends Node


signal cargo_loaded(cargo_id: String, quantity: int)
signal cargo_unloaded(cargo_id: String, quantity: int)
signal cargo_changed()

var inventory: CargoInventory
var capacity_tons: int = 0
var cargo_catalog: Dictionary = {}


func setup_from_train_data(train_data: TrainData, p_cargo_catalog: Dictionary = {}) -> void:
	cargo_catalog = p_cargo_catalog
	capacity_tons = train_data.capacity_tons if train_data != null else 0
	inventory = CargoInventory.new()
	inventory.set_capacity_tons(capacity_tons)


## Returns amount actually loaded
func load_cargo(cargo_id: String, quantity: int) -> int:
	if inventory == null:
		push_error("TrainCargo: inventory not initialized")
		return 0
	var added := inventory.add_cargo(cargo_id, quantity, cargo_catalog)
	if added > 0:
		cargo_loaded.emit(cargo_id, added)
		cargo_changed.emit()
	return added


## Returns amount actually unloaded
func unload_cargo(cargo_id: String, quantity: int) -> int:
	if inventory == null:
		push_error("TrainCargo: inventory not initialized")
		return 0
	var removed := inventory.remove_cargo(cargo_id, quantity)
	if removed > 0:
		cargo_unloaded.emit(cargo_id, removed)
		cargo_changed.emit()
	return removed


## Unloads all cargo to target inventory. Returns total units unloaded.
func unload_all_to(target_inventory: CargoInventory) -> int:
	if inventory == null:
		return 0
	var total_unloaded := 0
	# Copy stacks to avoid modifying while iterating
	var current_stacks: Array[CargoStackState] = inventory.stacks.duplicate()
	for stack in current_stacks:
		var removed := inventory.remove_cargo(stack.cargo_id, stack.quantity)
		if removed > 0:
			var added := target_inventory.add_cargo(stack.cargo_id, removed, cargo_catalog)
			# Return overflow to train if target can't hold it
			if added < removed:
				inventory.add_cargo(stack.cargo_id, removed - added, cargo_catalog)
			total_unloaded += added
			cargo_unloaded.emit(stack.cargo_id, added)
	if total_unloaded > 0:
		cargo_changed.emit()
	return total_unloaded


func get_quantity(cargo_id: String) -> int:
	if inventory == null:
		return 0
	return inventory.get_quantity(cargo_id)


func is_empty() -> bool:
	if inventory == null:
		return true
	return inventory.get_total_quantity() == 0


func get_used_capacity_tons() -> float:
	if inventory == null:
		return 0.0
	return inventory.get_used_capacity_tons(cargo_catalog)


func get_available_capacity_tons() -> float:
	if inventory == null:
		return 0.0
	return inventory.get_available_capacity_tons(cargo_catalog)
