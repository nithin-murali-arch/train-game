class_name ObjectivePanel
extends PanelContainer


signal closed()

@onready var _title_label: Label = %TitleLabel
@onready var _act_description_label: Label = %ActDescriptionLabel
@onready var _objectives_list: VBoxContainer = %ObjectivesList
@onready var _next_act_hint_label: Label = %NextActHintLabel
@onready var _close_btn: Button = %CloseButton

var _campaign_manager: CampaignManager = null


func _ready() -> void:
	_close_btn.pressed.connect(_on_close)
	visible = false


func open(campaign_manager: CampaignManager) -> void:
	_campaign_manager = campaign_manager
	refresh()
	visible = true


func close() -> void:
	visible = false


func refresh() -> void:
	_clear_list(_objectives_list)

	if _campaign_manager == null:
		_title_label.text = "Objectives"
		_act_description_label.text = ""
		_next_act_hint_label.text = ""
		return

	var act := _campaign_manager.get_current_act()
	if act == null:
		_title_label.text = "Objectives"
		_act_description_label.text = "No active act."
		_next_act_hint_label.text = ""
		return

	_title_label.text = act.display_name
	_act_description_label.text = act.description

	var objectives := _campaign_manager.get_current_objectives()
	for obj in objectives:
		var row := _create_objective_row(obj)
		_objectives_list.add_child(row)

	if objectives.is_empty():
		var empty := Label.new()
		empty.text = "No objectives"
		_objectives_list.add_child(empty)

	if not act.next_act_hint.is_empty():
		_next_act_hint_label.text = "Next: %s" % act.next_act_hint.capitalize()
	else:
		_next_act_hint_label.text = "Final Act"


func _clear_list(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()


func _create_objective_row(objective: CampaignObjective) -> Control:
	var panel := PanelContainer.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	margin.add_child(vbox)

	# Title row with completion indicator
	var hbox := HBoxContainer.new()
	vbox.add_child(hbox)

	var status := Label.new()
	status.text = "✓ " if objective.is_complete else "○ "
	status.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2) if objective.is_complete else Color(0.7, 0.7, 0.7))
	hbox.add_child(status)

	var title := Label.new()
	title.text = objective.display_name
	title.add_theme_font_size_override("font_size", 14)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(title)

	# Description
	var desc := Label.new()
	desc.text = objective.description
	desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(desc)

	# Progress bar
	var progress := ProgressBar.new()
	var ratio := 1.0 if objective.is_complete else clampf(float(objective.current_value) / float(maxi(objective.target_value, 1)), 0.0, 1.0)
	progress.value = ratio * 100.0
	progress.max_value = 100.0
	progress.custom_minimum_size = Vector2(0, 12)
	vbox.add_child(progress)

	# Progress text
	var prog_text := Label.new()
	prog_text.text = objective.get_progress_text()
	prog_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vbox.add_child(prog_text)

	return panel


func _on_close() -> void:
	closed.emit()
	close()
