class_name DataCatalog
extends RefCounted


# ============================================================================
# Hardcoded seed resource paths
# ============================================================================

const _CARGO_PATHS: Array[String] = [
	"res://data/cargo/coal.tres",
	"res://data/cargo/textiles.tres",
	"res://data/cargo/grain.tres",
]

const _TRAIN_PATHS: Array[String] = [
	"res://data/trains/freight_engine.tres",
	"res://data/trains/mixed_engine.tres",
]

const _CITY_PATHS: Array[String] = [
	"res://data/cities/kolkata.tres",
	"res://data/cities/dacca.tres",
	"res://data/cities/patna.tres",
	"res://data/cities/murshidabad.tres",
]

const _REGION_PATHS: Array[String] = [
	"res://data/regions/bengal.tres",
]

const _FACTION_PATHS: Array[String] = [
	"res://data/factions/player_railway_company.tres",
]

const _ERA_PATHS: Array[String] = [
	"res://data/eras/colonial.tres",
]


# ============================================================================
# Grouped storage
# ============================================================================

var cargos: Array[CargoData] = []
var trains: Array[TrainData] = []
var cities: Array[CityData] = []
var regions: Array[RegionData] = []
var factions: Array[FactionData] = []
var eras: Array[EraData] = []

var cargo_by_id: Dictionary = {}   ## String -> CargoData
var train_by_id: Dictionary = {}   ## String -> TrainData
var city_by_id: Dictionary = {}    ## String -> CityData
var region_by_id: Dictionary = {}  ## String -> RegionData
var faction_by_id: Dictionary = {} ## String -> FactionData
var era_by_id: Dictionary = {}     ## String -> EraData

## type_name -> Array[String] of duplicate IDs detected during load
var duplicate_ids: Dictionary = {}


# ============================================================================
# Lifecycle
# ============================================================================

func _init() -> void:
	_load_all()


func _load_all() -> void:
	_load_type(_CARGO_PATHS, cargos, cargo_by_id, "cargo")
	_load_type(_TRAIN_PATHS, trains, train_by_id, "train")
	_load_type(_CITY_PATHS, cities, city_by_id, "city")
	_load_type(_REGION_PATHS, regions, region_by_id, "region")
	_load_type(_FACTION_PATHS, factions, faction_by_id, "faction")
	_load_type(_ERA_PATHS, eras, era_by_id, "era")


func _load_type(
	paths: Array[String],
	out_array: Array,
	out_lookup: Dictionary,
	type_name: String
) -> void:
	var seen_ids: Dictionary = {}

	for path in paths:
		var res: Resource = ResourceLoader.load(path)
		if res == null:
			push_error("DataCatalog: failed to load %s at %s" % [type_name, path])
			continue

		out_array.append(res)

		var id: String = _get_id(res)
		if id.is_empty():
			push_error("DataCatalog: %s has empty id at %s" % [type_name, path])
			continue

		if id in seen_ids:
			if not duplicate_ids.has(type_name):
				duplicate_ids[type_name] = [] as Array[String]
			var dupes: Array[String] = duplicate_ids[type_name]
			if not dupes.has(id):
				dupes.append(id)
			push_error("DataCatalog: duplicate %s id '%s' at %s" % [type_name, id, path])
			continue

		seen_ids[id] = true
		out_lookup[id] = res


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


# ============================================================================
# Typed getters
# ============================================================================

func get_cargo_by_id(id: String) -> CargoData:
	return cargo_by_id.get(id, null) as CargoData


func get_train_by_id(id: String) -> TrainData:
	return train_by_id.get(id, null) as TrainData


func get_city_by_id(id: String) -> CityData:
	return city_by_id.get(id, null) as CityData


func get_region_by_id(id: String) -> RegionData:
	return region_by_id.get(id, null) as RegionData


func get_faction_by_id(id: String) -> FactionData:
	return faction_by_id.get(id, null) as FactionData


func get_era_by_id(id: String) -> EraData:
	return era_by_id.get(id, null) as EraData
