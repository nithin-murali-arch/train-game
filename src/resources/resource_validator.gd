class_name ResourceValidator
extends RefCounted


# ============================================================================
# Dependencies
# ============================================================================

var _catalog: DataCatalog


# ============================================================================
# Lifecycle
# ============================================================================

func _init(catalog: DataCatalog) -> void:
	_catalog = catalog


# ============================================================================
# Public API
# ============================================================================

## Validates every resource in the catalog, checks duplicate IDs, and verifies
## cross-references. Returns a structured Dictionary:
## {
##   "is_valid": bool,
##   "errors": Array[String],
##   "by_type": {
##     "cargo": { "count": int, "errors": Array[String], "resources": { "coal": { "is_valid": bool, "errors": Array[String] }, ... } },
##     ...
##   }
## }
func validate_all() -> Dictionary:
	var result := {
		"is_valid": true,
		"errors": [] as Array[String],
		"by_type": {} as Dictionary,
	}

	_validate_type(result, "cargo", _catalog.cargos)
	_validate_type(result, "train", _catalog.trains)
	_validate_type(result, "city", _catalog.cities)
	_validate_type(result, "region", _catalog.regions)
	_validate_type(result, "faction", _catalog.factions)
	_validate_type(result, "era", _catalog.eras)

	_validate_cross_references(result)

	result.is_valid = (result.errors as Array[String]).is_empty()
	return result


# ============================================================================
# Internal helpers
# ============================================================================

func _validate_type(
	result: Dictionary,
	type_name: String,
	resources: Array
) -> void:
	var type_result := {
		"count": resources.size(),
		"errors": [] as Array[String],
		"resources": {} as Dictionary,
	}

	# Duplicate ID detection
	var seen_ids: Dictionary = {}
	for res in resources:
		var id := _get_id(res)
		if id.is_empty():
			continue
		if id in seen_ids:
			var msg := "%s: duplicate id '%s'" % [type_name, id]
			type_result.errors.append(msg)
			result.errors.append(msg)
		seen_ids[id] = true

	# Individual resource validation
	for res in resources:
		var id := _get_id(res)
		var res_errors: Array[String] = []
		if res.has_method("validate"):
			res_errors = res.call("validate") as Array[String]

		var res_result := {
			"is_valid": res_errors.is_empty(),
			"errors": res_errors.duplicate(),
		}
		if not id.is_empty():
			type_result.resources[id] = res_result

		for err in res_errors:
			var msg := "%s[%s]: %s" % [type_name, id, err]
			type_result.errors.append(msg)
			result.errors.append(msg)

	result.by_type[type_name] = type_result


func _validate_cross_references(result: Dictionary) -> void:
	# RegionData.era_id must exist in EraData IDs
	for region in _catalog.regions:
		if not _catalog.era_by_id.has(region.era_id):
			var msg := "region[%s]: era_id '%s' does not exist in eras" % [region.region_id, region.era_id]
			_append_error(result, "region", msg)

	# RegionData.city_ids entries must exist in CityData IDs
	for region in _catalog.regions:
		for city_id in region.city_ids:
			if not _catalog.city_by_id.has(city_id):
				var msg := "region[%s]: city_ids contains unknown city '%s'" % [region.region_id, city_id]
				_append_error(result, "region", msg)

	# RegionData.starting_city_id must exist in RegionData.city_ids
	for region in _catalog.regions:
		if not region.starting_city_id.is_empty() and not region.city_ids.has(region.starting_city_id):
			var msg := "region[%s]: starting_city_id '%s' not in city_ids" % [region.region_id, region.starting_city_id]
			_append_error(result, "region", msg)

	# EraData.available_cargo_ids entries must exist in CargoData IDs
	for era in _catalog.eras:
		for cargo_id in era.available_cargo_ids:
			if not _catalog.cargo_by_id.has(cargo_id):
				var msg := "era[%s]: available_cargo_ids contains unknown cargo '%s'" % [era.era_id, cargo_id]
				_append_error(result, "era", msg)

	# EraData.available_train_ids entries must exist in TrainData IDs
	for era in _catalog.eras:
		for train_id in era.available_train_ids:
			if not _catalog.train_by_id.has(train_id):
				var msg := "era[%s]: available_train_ids contains unknown train '%s'" % [era.era_id, train_id]
				_append_error(result, "era", msg)

	# EraData.available_faction_ids entries must exist in FactionData IDs
	for era in _catalog.eras:
		for faction_id in era.available_faction_ids:
			if not _catalog.faction_by_id.has(faction_id):
				var msg := "era[%s]: available_faction_ids contains unknown faction '%s'" % [era.era_id, faction_id]
				_append_error(result, "era", msg)

	# CityCargoProfileData.cargo_id must exist in CargoData IDs
	for city in _catalog.cities:
		for profile in city.cargo_profiles:
			if profile == null:
				continue
			if not _catalog.cargo_by_id.has(profile.cargo_id):
				var msg := "city[%s]: cargo_profile references unknown cargo '%s'" % [city.city_id, profile.cargo_id]
				_append_error(result, "city", msg)


func _get_id(resource: Resource) -> String:
	if resource is CargoData:
		return (resource as CargoData).cargo_id
	elif resource is TrainData:
		return (resource as TrainData).train_id
	elif resource is CityData:
		return (resource as CityData).city_id
	elif resource is RegionData:
		return (resource as RegionData).region_id
	elif resource is FactionData:
		return (resource as FactionData).faction_id
	elif resource is EraData:
		return (resource as EraData).era_id
	return ""


func _append_error(result: Dictionary, type_name: String, message: String) -> void:
	result.errors.append(message)
	if result.by_type.has(type_name):
		(result.by_type[type_name] as Dictionary)["errors"].append(message)
