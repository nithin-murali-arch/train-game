class_name CityData
extends Resource

@export var city_id: String = ""
@export var display_name: String = ""
@export var role: String = ""
@export var map_position: Vector2i = Vector2i.ZERO
@export var population_tier: String = "medium"
@export var cargo_profiles: Array[CityCargoProfileData] = []
@export var special_modifiers: Array[ModifierValueData] = []
@export var tags: Array[String] = []

func validate() -> Array[String]:
	var errors: Array[String] = []

	if city_id.strip_edges().is_empty():
		errors.append("city_id is required")
	elif city_id != city_id.to_snake_case():
		errors.append("city_id must be lowercase snake_case: " + city_id)

	if display_name.strip_edges().is_empty():
		errors.append("display_name is required")

	if role.strip_edges().is_empty():
		errors.append("role is required")

	if population_tier.strip_edges().is_empty():
		errors.append("population_tier is required")

	var seen_cargo_ids: Dictionary = {}
	for i in range(cargo_profiles.size()):
		var profile := cargo_profiles[i]
		if profile == null:
			errors.append("cargo_profiles[%d] is null" % i)
			continue
		var profile_errors := profile.validate()
		for err in profile_errors:
			errors.append("cargo_profiles[%d]: %s" % [i, err])
		if profile.cargo_id in seen_cargo_ids:
			errors.append("cargo_profiles[%d]: duplicate cargo_id '%s'" % [i, profile.cargo_id])
		seen_cargo_ids[profile.cargo_id] = true

	for i in range(special_modifiers.size()):
		var modifier := special_modifiers[i]
		if modifier == null:
			errors.append("special_modifiers[%d] is null" % i)
			continue
		var modifier_errors := modifier.validate()
		for err in modifier_errors:
			errors.append("special_modifiers[%d]: %s" % [i, err])

	for i in range(tags.size()):
		if tags[i].strip_edges().is_empty():
			errors.append("tags[%d] is empty" % i)

	return errors
