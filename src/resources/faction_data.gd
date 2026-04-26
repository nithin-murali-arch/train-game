class_name FactionData
extends Resource

@export var faction_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var color: Color = Color.WHITE
@export var starting_capital: int = 0
@export var bonus_values: Array[ModifierValueData] = []
@export var ai_personality: String = "none"
@export var is_player_selectable: bool = false
@export var logo_texture: Texture2D

func validate() -> Array[String]:
	var errors: Array[String] = []

	if faction_id.strip_edges().is_empty():
		errors.append("faction_id is required")
	elif faction_id != faction_id.to_snake_case():
		errors.append("faction_id must be lowercase snake_case: " + faction_id)

	if display_name.strip_edges().is_empty():
		errors.append("display_name is required")

	if starting_capital < 0:
		errors.append("starting_capital must be non-negative")

	if ai_personality.strip_edges().is_empty():
		errors.append("ai_personality is required")

	for modifier in bonus_values:
		if modifier == null:
			errors.append("bonus_values contains null entry")
			break
		var modifier_errors := modifier.validate()
		for err in modifier_errors:
			errors.append("bonus_values: " + err)

	return errors
