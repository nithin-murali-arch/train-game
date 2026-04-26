class_name EraData
extends Resource

@export var era_id: String = ""
@export var display_name: String = ""
@export var start_year: int = 0
@export var end_year: int = 0
@export var available_cargo_ids: Array[String] = []
@export var available_train_ids: Array[String] = []
@export var available_faction_ids: Array[String] = []
@export var maintenance_multiplier: float = 1.0
@export var pricing_multiplier: float = 1.0
@export var ui_theme_id: String = ""
@export var era_modifiers: Array[ModifierValueData] = []

func validate() -> Array[String]:
	var errors: Array[String] = []

	if era_id.strip_edges().is_empty():
		errors.append("era_id is required")
	elif era_id != era_id.to_snake_case():
		errors.append("era_id must be lowercase snake_case: " + era_id)

	if display_name.strip_edges().is_empty():
		errors.append("display_name is required")

	if start_year > end_year:
		errors.append("start_year must be less than or equal to end_year")

	_validate_id_array(errors, available_cargo_ids, "available_cargo_ids")
	_validate_id_array(errors, available_train_ids, "available_train_ids")
	_validate_id_array(errors, available_faction_ids, "available_faction_ids")

	if maintenance_multiplier <= 0.0:
		errors.append("maintenance_multiplier must be greater than zero")

	if pricing_multiplier <= 0.0:
		errors.append("pricing_multiplier must be greater than zero")

	if ui_theme_id.strip_edges().is_empty():
		errors.append("ui_theme_id is required")

	for modifier in era_modifiers:
		if modifier == null:
			errors.append("era_modifiers contains null entry")
			break
		var modifier_errors := modifier.validate()
		for err in modifier_errors:
			errors.append("era_modifiers: " + err)

	return errors

func _validate_id_array(errors: Array[String], ids: Array[String], field_name: String) -> void:
	if ids.is_empty():
		errors.append(field_name + " must not be empty")
		return

	var seen: Dictionary = {}
	for id in ids:
		if id.strip_edges().is_empty():
			errors.append(field_name + " contains empty string")
			break
		if seen.has(id):
			errors.append(field_name + " contains duplicate: " + id)
			break
		seen[id] = true
