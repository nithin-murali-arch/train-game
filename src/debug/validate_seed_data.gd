class_name ValidateSeedData
extends Node

func _ready() -> void:
	var catalog := DataCatalog.new()
	var validator := ResourceValidator.new(catalog)

	print("=== Rail Empire Seed Data Validation ===")
	var total := catalog.cargos.size() + catalog.trains.size() + catalog.cities.size() + catalog.regions.size() + catalog.factions.size() + catalog.eras.size()
	print("Resources loaded: %d" % total)
	print("")

	var result := validator.validate_all()
	var is_valid: bool = result.is_valid
	var errors: Array[String] = result.errors
	var by_type: Dictionary = result.by_type

	# Print per-type summary
	var type_names := ["cargo", "train", "city", "region", "faction", "era"]
	for type_name in type_names:
		if not by_type.has(type_name):
			continue
		var type_result: Dictionary = by_type[type_name]
		var count: int = type_result.count
		var type_errors: Array[String] = type_result.errors
		print("[%s] %d resource(s)" % [type_name.capitalize(), count])
		if type_errors.is_empty():
			print("  PASS")
		else:
			print("  FAIL (%d errors)" % type_errors.size())
			for err in type_errors:
				print("    - %s" % err)
		print("")

	# Overall result
	print("================================")
	if is_valid:
		print("RAIL EMPIRE SEED DATA VALIDATION: PASS")
	else:
		print("RAIL EMPIRE SEED DATA VALIDATION: FAIL")
		print("Total errors: %d" % errors.size())

	get_tree().quit()
