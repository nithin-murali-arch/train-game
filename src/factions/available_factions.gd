class_name AvailableFactions
extends RefCounted


static func get_all_factions() -> Array[FactionBonusData]:
	var factions: Array[FactionBonusData] = []

	var british := FactionBonusData.new()
	british.faction_id = "british"
	british.display_name = "British East India Railway"
	british.description = "Well-funded colonial operator with efficient maintenance."
	british.bonus_type = "maintenance_discount"
	british.bonus_value = 0.15
	factions.append(british)

	var french := FactionBonusData.new()
	french.faction_id = "french"
	french.display_name = "French Colonial Rail"
	french.description = "Skilled negotiators with strong diplomatic ties."
	french.bonus_type = "contract_reputation_bonus"
	french.bonus_value = 2.0
	factions.append(french)

	var amdani := FactionBonusData.new()
	amdani.faction_id = "amdani"
	amdani.display_name = "Amdani Railways"
	amdani.description = "Local expertise reduces infrastructure costs."
	amdani.bonus_type = "track_cost_discount"
	amdani.bonus_value = 0.15
	factions.append(amdani)

	return factions


static func get_bonus_for_faction(faction_id: String) -> FactionBonusData:
	for bonus in get_all_factions():
		if bonus.faction_id == faction_id:
			return bonus
	return null


static func get_all_bonuses_for_faction(faction_id: String) -> Array[FactionBonusData]:
	var result: Array[FactionBonusData] = []
	var primary := get_bonus_for_faction(faction_id)
	if primary != null:
		result.append(primary)
	if faction_id == "amdani":
		var station_bonus := FactionBonusData.new()
		station_bonus.faction_id = "amdani"
		station_bonus.display_name = "Amdani Railways"
		station_bonus.description = "Local expertise reduces infrastructure costs."
		station_bonus.bonus_type = "station_cost_discount"
		station_bonus.bonus_value = 0.15
		result.append(station_bonus)
	return result
