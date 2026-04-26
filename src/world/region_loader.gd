class_name RegionLoader
extends RefCounted


var catalog: DataCatalog
var region: RegionData
var cities: Array[CityData] = []


func _init(target_region_id: String = "bengal") -> void:
	catalog = DataCatalog.new()
	region = catalog.get_region_by_id(target_region_id)
	if region == null:
		push_error("RegionLoader: region '%s' not found" % target_region_id)
		return

	for city_id in region.city_ids:
		var city := catalog.get_city_by_id(city_id)
		if city == null:
			push_error("RegionLoader: city '%s' not found in catalog" % city_id)
			continue
		cities.append(city)
