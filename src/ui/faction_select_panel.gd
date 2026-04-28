class_name FactionSelectPanel
extends PanelContainer


signal faction_selected(faction_id: String)
signal closed()

@onready var _title_label: Label = %TitleLabel
@onready var _cards_container: HBoxContainer = %CardsContainer
@onready var _close_btn: Button = %CloseButton


func _ready() -> void:
	_close_btn.pressed.connect(_on_close)
	visible = false


func open() -> void:
	_clear_cards()
	var factions := AvailableFactions.get_all_factions()
	for faction in factions:
		var card := _create_faction_card(faction)
		_cards_container.add_child(card)
	visible = true


func close() -> void:
	visible = false


func _clear_cards() -> void:
	for child in _cards_container.get_children():
		child.queue_free()


func _create_faction_card(faction: FactionBonusData) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	margin.add_child(vbox)

	var name_label := Label.new()
	name_label.text = faction.display_name
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	var desc := Label.new()
	desc.text = faction.description
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(desc)

	var bonuses := AvailableFactions.get_all_bonuses_for_faction(faction.faction_id)
	var bonuses_label := Label.new()
	var bonus_lines: Array[String] = []
	for bonus in bonuses:
		bonus_lines.append(_format_bonus(bonus))
	bonuses_label.text = "Bonuses:\n" + "\n".join(bonus_lines)
	bonuses_label.add_theme_color_override("font_color", Color(0.8, 0.7, 0.5))
	vbox.add_child(bonuses_label)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var select_btn := Button.new()
	select_btn.text = "Select"
	select_btn.pressed.connect(func(): _on_select(faction.faction_id))
	vbox.add_child(select_btn)

	return panel


func _format_bonus(bonus: FactionBonusData) -> String:
	match bonus.bonus_type:
		"maintenance_discount":
			return "  • Maintenance cost -%.0f%%" % (bonus.bonus_value * 100.0)
		"contract_reputation_bonus":
			return "  • Contract reputation +%.0f" % bonus.bonus_value
		"track_cost_discount":
			return "  • Track build cost -%.0f%%" % (bonus.bonus_value * 100.0)
		"station_cost_discount":
			return "  • Station upgrade cost -%.0f%%" % (bonus.bonus_value * 100.0)
		_:
			return "  • %s" % bonus.bonus_type


func _on_select(faction_id: String) -> void:
	faction_selected.emit(faction_id)


func _on_close() -> void:
	closed.emit()
	close()
