class_name CargoInventory
extends RefCounted


var capacity_tons: int = 0
var stacks: Array[CargoStackState] = []


func set_capacity_tons(value: int) -> void:
	capacity_tons = value


func get_quantity(cargo_id: String) -> int:
	for stack in stacks:
		if stack.cargo_id == cargo_id:
			return stack.quantity
	return 0


func get_total_quantity() -> int:
	var total := 0
	for stack in stacks:
		total += stack.quantity
	return total


func get_used_capacity_tons(cargo_catalog: Dictionary = {}) -> float:
	var total := 0.0
	for stack in stacks:
		var weight := _get_weight_per_unit(stack.cargo_id, cargo_catalog)
		total += stack.quantity * weight
	return total


func get_available_capacity_tons(cargo_catalog: Dictionary = {}) -> float:
	return float(capacity_tons) - get_used_capacity_tons(cargo_catalog)


func can_add(cargo_id: String, quantity: int, cargo_catalog: Dictionary = {}) -> bool:
	if quantity <= 0:
		return false
	var weight := _get_weight_per_unit(cargo_id, cargo_catalog)
	var needed_capacity := float(quantity) * weight
	return needed_capacity <= get_available_capacity_tons(cargo_catalog) + 0.0001


## Returns the amount actually added (may be less than requested due to capacity)
func add_cargo(cargo_id: String, quantity: int, cargo_catalog: Dictionary = {}) -> int:
	if quantity <= 0:
		return 0

	var weight := _get_weight_per_unit(cargo_id, cargo_catalog)
	var available := get_available_capacity_tons(cargo_catalog)
	var max_by_capacity := int(floorf(available / weight))
	var to_add := mini(quantity, max_by_capacity)

	if to_add <= 0:
		return 0

	# Find existing stack or create new
	var found := false
	for stack in stacks:
		if stack.cargo_id == cargo_id:
			stack.quantity += to_add
			found = true
			break

	if not found:
		stacks.append(CargoStackState.new(cargo_id, to_add))

	return to_add


## Returns the amount actually removed (may be less than requested)
func remove_cargo(cargo_id: String, quantity: int) -> int:
	if quantity <= 0:
		return 0

	for i in range(stacks.size()):
		var stack: CargoStackState = stacks[i]
		if stack.cargo_id == cargo_id:
			var to_remove := mini(quantity, stack.quantity)
			stack.quantity -= to_remove
			if stack.quantity <= 0:
				stacks.remove_at(i)
			return to_remove

	return 0


## Returns the amount actually transferred
func transfer_to(target_inventory: CargoInventory, cargo_id: String, quantity: int, cargo_catalog: Dictionary = {}) -> int:
	if quantity <= 0:
		return 0
	var removed := remove_cargo(cargo_id, quantity)
	if removed <= 0:
		return 0
	var added := target_inventory.add_cargo(cargo_id, removed, cargo_catalog)
	# If target couldn't take all, return overflow to self
	if added < removed:
		add_cargo(cargo_id, removed - added, cargo_catalog)
	return added


func clear() -> void:
	stacks.clear()


func validate(cargo_catalog: Dictionary = {}) -> Array[String]:
	var errors: Array[String] = []

	if capacity_tons < 0:
		errors.append("capacity_tons must be non-negative")

	var used := get_used_capacity_tons(cargo_catalog)
	if used > float(capacity_tons) + 0.0001:
		errors.append("used capacity %.1f exceeds capacity %d" % [used, capacity_tons])

	var seen_ids: Dictionary = {}
	for stack in stacks:
		var stack_errors := stack.validate()
		for err in stack_errors:
			errors.append("stack[%s]: %s" % [stack.cargo_id, err])
		if stack.cargo_id in seen_ids:
			errors.append("duplicate stack for cargo_id: " + stack.cargo_id)
		seen_ids[stack.cargo_id] = true

	return errors


func _get_weight_per_unit(cargo_id: String, cargo_catalog: Dictionary) -> float:
	if cargo_catalog.has(cargo_id):
		var cargo: CargoData = cargo_catalog[cargo_id] as CargoData
		if cargo != null:
			return cargo.weight_per_unit
	return 1.0
