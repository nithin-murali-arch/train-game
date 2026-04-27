class_name MarketShareSystem
extends RefCounted


var _ledger: DeliveryLedger = null


func setup(ledger: DeliveryLedger) -> void:
	_ledger = ledger


func get_city_market_share(city_id: String, faction_id: String) -> float:
	if _ledger == null:
		return 0.0

	var total_for_city := _ledger.get_total_quantity_for_city(city_id)
	if total_for_city <= 0:
		return 0.0

	var faction_for_city := _ledger.get_total_quantity_for_faction_city(faction_id, city_id)
	return float(faction_for_city) / float(total_for_city)


func get_overall_market_share(faction_id: String) -> float:
	if _ledger == null:
		return 0.0

	var total := _ledger.get_total_quantity()
	if total <= 0:
		return 0.0

	var faction_total := _ledger.get_total_quantity_for_faction(faction_id)
	return float(faction_total) / float(total)


func get_city_delivery_counts(city_id: String) -> Dictionary:
	var result: Dictionary = {}
	if _ledger == null:
		return result

	var total_for_city := _ledger.get_total_quantity_for_city(city_id)
	if total_for_city <= 0:
		return result

	var faction_ids: Array[String] = [
		"player_railway_company",
		"british_east_india_rail",
	]
	for fid in faction_ids:
		var qty := _ledger.get_total_quantity_for_faction_city(fid, city_id)
		if qty > 0:
			result[fid] = qty

	return result


func to_dict() -> Dictionary:
	return {}


func from_dict(_data: Dictionary) -> void:
	pass
