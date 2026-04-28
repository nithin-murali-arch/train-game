class_name ScenarioSelectPanel
extends PanelContainer


signal scenario_selected(scenario_id: String)
signal closed()

@onready var _title_label: Label = %TitleLabel
@onready var _cards_container: HBoxContainer = %CardsContainer
@onready var _close_btn: Button = %CloseButton


func _ready() -> void:
	_close_btn.pressed.connect(_on_close)
	visible = false


func open() -> void:
	_clear_cards()

	var scenarios: Array[ScenarioData] = [
		Scenarios.create_bengal_charter_scenario(),
		Scenarios.create_port_monopoly_scenario(),
		Scenarios.create_monsoon_crisis_scenario(),
	]

	for scenario in scenarios:
		var card := _create_scenario_card(scenario)
		_cards_container.add_child(card)

	visible = true


func close() -> void:
	visible = false


func _clear_cards() -> void:
	for child in _cards_container.get_children():
		child.queue_free()


func _create_scenario_card(scenario: ScenarioData) -> Control:
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
	name_label.text = scenario.display_name
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	var desc := Label.new()
	desc.text = scenario.description
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(desc)

	# Starting conditions
	var conditions := Label.new()
	var lines: Array[String] = ["Starting Capital: ₹%s" % _comma_sep(scenario.starting_money)]
	if not scenario.prebuilt_track.is_empty():
		lines.append("Pre-built Track: %d segments" % scenario.prebuilt_track.size())
	if not scenario.starting_trains.is_empty():
		lines.append("Starting Trains: %d" % scenario.starting_trains.size())
	if not scenario.modifiers.is_empty():
		for key in scenario.modifiers.keys():
			lines.append("Modifier: %s ×%.2f" % [key, scenario.modifiers[key]])
	conditions.text = "\n".join(lines)
	conditions.add_theme_color_override("font_color", Color(0.8, 0.7, 0.5))
	vbox.add_child(conditions)

	# Objectives summary
	var obj_label := Label.new()
	var obj_lines: Array[String] = ["Objectives:"]
	for obj in scenario.objectives:
		obj_lines.append("  • %s" % obj.display_name)
	obj_label.text = "\n".join(obj_lines)
	obj_label.add_theme_color_override("font_color", Color(0.7, 0.8, 0.7))
	vbox.add_child(obj_label)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var start_btn := Button.new()
	start_btn.text = "Start"
	start_btn.pressed.connect(func(): _on_start(scenario.scenario_id))
	vbox.add_child(start_btn)

	return panel


func _on_start(scenario_id: String) -> void:
	scenario_selected.emit(scenario_id)


func _on_close() -> void:
	closed.emit()
	close()


static func _comma_sep(n: int) -> String:
	var s := str(n)
	var result := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result
