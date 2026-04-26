class_name StationArrivalHandler
extends Node


var _city_by_grid: Dictionary = {}  # "x,y" -> CityRuntimeState
var _city_by_id: Dictionary = {}    # city_id -> CityRuntimeState
var _cargo_catalog: Dictionary = {}
var _treasury: TreasuryState


func setup(cities: Array[CityRuntimeState], treasury: TreasuryState, cargo_catalog: Dictionary) -> void:
	_treasury = treasury
	_cargo_catalog = cargo_catalog
	_city_by_grid.clear()
	_city_by_id.clear()

	for city in cities:
		var key: String = "%d,%d" % [city.grid_coord.x, city.grid_coord.y]
		_city_by_grid[key] = city
		_city_by_id[city.city_id] = city


func connect_train(train: TrainEntity) -> void:
	var movement: TrainMovement = train.get_node("TrainMovement") as TrainMovement
	if movement == null:
		push_error("StationArrivalHandler: train has no TrainMovement")
		return
	movement.destination_arrived.connect(_on_train_arrived.bind(train))


func _on_train_arrived(coord: Vector2i, train: TrainEntity) -> void:
	var key: String = "%d,%d" % [coord.x, coord.y]
	if not _city_by_grid.has(key):
		print("STATION ARRIVAL: no city at coord %s" % coord)
		return

	var city: CityRuntimeState = _city_by_grid[key]
	var train_cargo: TrainCargo = train.get_train_cargo()
	if train_cargo == null:
		print("STATION ARRIVAL: train has no cargo component")
		return

	print("Destination arrived: %s" % city.display_name)

	# Unload all cargo to city inventory
	var unloaded_total := 0
	for stack in train_cargo.inventory.stacks.duplicate():
		var quantity_before := city.get_quantity(stack.cargo_id)
		var unloaded := train_cargo.unload_all_to(city.inventory)
		var quantity_after := city.get_quantity(stack.cargo_id)
		var actual_unloaded := quantity_after - quantity_before

		if actual_unloaded > 0:
			print("Unloaded %s to %s: %d" % [stack.cargo_id, city.display_name, actual_unloaded])
			unloaded_total += actual_unloaded

			# Execute fixed-price sale
			var revenue := Transaction.sell_cargo(stack.cargo_id, actual_unloaded, city, _treasury, _cargo_catalog)
			if revenue > 0:
				print("Sold %s: %d × ₹%.0f = ₹%d" % [stack.cargo_id, actual_unloaded, _get_base_price(stack.cargo_id), revenue])

	if unloaded_total == 0:
		print("Train arrived empty — no cargo to unload")

	print("Treasury: ₹%d" % _treasury.balance)


func _get_base_price(cargo_id: String) -> float:
	if _cargo_catalog.has(cargo_id):
		var cargo: CargoData = _cargo_catalog[cargo_id] as CargoData
		if cargo != null:
			return cargo.base_price
	return 0.0
