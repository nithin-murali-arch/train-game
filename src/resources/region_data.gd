class_name RegionData
extends Resource

@export var region_id: String = ""
@export var display_name: String = ""
@export var era_id: String = ""
@export var city_ids: Array[String] = []
@export var starting_city_id: String = ""
@export var terrain_seed: int = 0
@export var map_width: int = 64
@export var map_height: int = 64
@export var climate_tags: Array[String] = []
@export var terrain_profile: Array[TerrainProfileEntryData] = []
@export var regional_modifiers: Array[ModifierValueData] = []
@export var neighboring_region_ids: Array[String] = []

func validate() -> Array[String]:
	var errors: Array[String] = []

	if region_id.strip_edges().is_empty():
		errors.append("region_id is required")
	elif region_id != region_id.to_snake_case():
		errors.append("region_id must be lowercase snake_case: " + region_id)

	if display_name.strip_edges().is_empty():
		errors.append("display_name is required")

	if era_id.strip_edges().is_empty():
		errors.append("era_id is required")
	elif era_id != era_id.to_snake_case():
		errors.append("era_id must be lowercase snake_case: " + era_id)

	if map_width <= 0:
		errors.append("map_width must be greater than 0")

	if map_height <= 0:
		errors.append("map_height must be greater than 0")

	if city_ids.is_empty():
		errors.append("city_ids must not be empty")

	var seen_city_ids: Dictionary = {}
	for i in range(city_ids.size()):
		var cid := city_ids[i]
		if cid.strip_edges().is_empty():
			errors.append("city_ids[%d] is empty" % i)
			continue
		if cid in seen_city_ids:
			errors.append("city_ids[%d]: duplicate city_id '%s'" % [i, cid])
		seen_city_ids[cid] = true

	if starting_city_id.strip_edges().is_empty():
		errors.append("starting_city_id is required")
	elif not city_ids.has(starting_city_id):
		errors.append("starting_city_id '%s' must exist in city_ids" % starting_city_id)

	for i in range(climate_tags.size()):
		if climate_tags[i].strip_edges().is_empty():
			errors.append("climate_tags[%d] is empty" % i)

	for i in range(terrain_profile.size()):
		var entry := terrain_profile[i]
		if entry == null:
			errors.append("terrain_profile[%d] is null" % i)
			continue
		var entry_errors := entry.validate()
		for err in entry_errors:
			errors.append("terrain_profile[%d]: %s" % [i, err])

	for i in range(regional_modifiers.size()):
		var modifier := regional_modifiers[i]
		if modifier == null:
			errors.append("regional_modifiers[%d] is null" % i)
			continue
		var modifier_errors := modifier.validate()
		for err in modifier_errors:
			errors.append("regional_modifiers[%d]: %s" % [i, err])

	for i in range(neighboring_region_ids.size()):
		if neighboring_region_ids[i].strip_edges().is_empty():
			errors.append("neighboring_region_ids[%d] is empty" % i)

	return errors
