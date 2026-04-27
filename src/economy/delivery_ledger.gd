class_name DeliveryLedger
extends RefCounted


class DeliveryEntry:
	extends RefCounted

	var date_absolute_day: int = 0
	var faction_id: String = ""
	var route_instance_id: String = ""
	var train_instance_id: String = ""
	var origin_city_id: String = ""
	var destination_city_id: String = ""
	var cargo_id: String = ""
	var quantity: int = 0
	var revenue: int = 0
	var operating_cost: int = 0
	var profit: int = 0


var _entries: Array[DeliveryEntry] = []


func record_delivery(
	date_absolute_day: int,
	faction_id: String,
	route_instance_id: String,
	train_instance_id: String,
	origin_city_id: String,
	destination_city_id: String,
	cargo_id: String,
	quantity: int,
	revenue: int,
	operating_cost: int
) -> void:
	var entry := DeliveryEntry.new()
	entry.date_absolute_day = date_absolute_day
	entry.faction_id = faction_id
	entry.route_instance_id = route_instance_id
	entry.train_instance_id = train_instance_id
	entry.origin_city_id = origin_city_id
	entry.destination_city_id = destination_city_id
	entry.cargo_id = cargo_id
	entry.quantity = quantity
	entry.revenue = revenue
	entry.operating_cost = operating_cost
	entry.profit = revenue - operating_cost
	_entries.append(entry)


func get_all_entries() -> Array[DeliveryEntry]:
	return _entries.duplicate()


func get_entries_for_faction(faction_id: String) -> Array[DeliveryEntry]:
	var result: Array[DeliveryEntry] = []
	for entry in _entries:
		if entry.faction_id == faction_id:
			result.append(entry)
	return result


func get_entries_for_city(city_id: String) -> Array[DeliveryEntry]:
	var result: Array[DeliveryEntry] = []
	for entry in _entries:
		if entry.origin_city_id == city_id or entry.destination_city_id == city_id:
			result.append(entry)
	return result


func get_total_quantity_for_faction_city(faction_id: String, city_id: String) -> int:
	var total := 0
	for entry in _entries:
		if entry.faction_id == faction_id and entry.destination_city_id == city_id:
			total += entry.quantity
	return total


func get_total_quantity_for_city(city_id: String) -> int:
	var total := 0
	for entry in _entries:
		if entry.destination_city_id == city_id:
			total += entry.quantity
	return total


func get_total_quantity_for_faction(faction_id: String) -> int:
	var total := 0
	for entry in _entries:
		if entry.faction_id == faction_id:
			total += entry.quantity
	return total


func get_total_quantity() -> int:
	var total := 0
	for entry in _entries:
		total += entry.quantity
	return total


func clear() -> void:
	_entries.clear()


func to_dict() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in _entries:
		result.append({
			"date_absolute_day": entry.date_absolute_day,
			"faction_id": entry.faction_id,
			"route_instance_id": entry.route_instance_id,
			"train_instance_id": entry.train_instance_id,
			"origin_city_id": entry.origin_city_id,
			"destination_city_id": entry.destination_city_id,
			"cargo_id": entry.cargo_id,
			"quantity": entry.quantity,
			"revenue": entry.revenue,
			"operating_cost": entry.operating_cost,
			"profit": entry.profit,
		})
	return result


func from_dict(dict: Array) -> void:
	clear()
	for item in dict:
		var d: Dictionary = item as Dictionary
		if d == null:
			continue
		var entry := DeliveryEntry.new()
		entry.date_absolute_day = d.get("date_absolute_day", 0) as int
		entry.faction_id = d.get("faction_id", "") as String
		entry.route_instance_id = d.get("route_instance_id", "") as String
		entry.train_instance_id = d.get("train_instance_id", "") as String
		entry.origin_city_id = d.get("origin_city_id", "") as String
		entry.destination_city_id = d.get("destination_city_id", "") as String
		entry.cargo_id = d.get("cargo_id", "") as String
		entry.quantity = d.get("quantity", 0) as int
		entry.revenue = d.get("revenue", 0) as int
		entry.operating_cost = d.get("operating_cost", 0) as int
		entry.profit = d.get("profit", 0) as int
		_entries.append(entry)
