class_name BriefingPanel
extends PanelContainer


signal begin_pressed()
signal closed()

@onready var _title_label: Label = %TitleLabel
@onready var _description_label: Label = %DescriptionLabel
@onready var _objectives_list: VBoxContainer = %ObjectivesList
@onready var _begin_btn: Button = %BeginButton
@onready var _close_btn: Button = %CloseButton


func _ready() -> void:
	_begin_btn.pressed.connect(_on_begin)
	_close_btn.pressed.connect(_on_close)
	visible = false


func open(act_data: CampaignData.CampaignActData) -> void:
	_title_label.text = act_data.display_name if act_data != null else "Briefing"
	_description_label.text = act_data.description if act_data != null else ""

	_clear_list(_objectives_list)
	if act_data != null:
		for obj in act_data.objectives:
			var row := _create_objective_row(obj)
			_objectives_list.add_child(row)

	if _objectives_list.get_child_count() == 0:
		var empty := Label.new()
		empty.text = "No objectives"
		_objectives_list.add_child(empty)

	visible = true


func open_scenario(scenario_data: ScenarioData) -> void:
	_title_label.text = scenario_data.display_name if scenario_data != null else "Scenario"
	_description_label.text = scenario_data.description if scenario_data != null else ""

	_clear_list(_objectives_list)
	if scenario_data != null:
		for obj in scenario_data.objectives:
			var row := _create_objective_row(obj)
			_objectives_list.add_child(row)

	if _objectives_list.get_child_count() == 0:
		var empty := Label.new()
		empty.text = "No objectives"
		_objectives_list.add_child(empty)

	visible = true


func close() -> void:
	visible = false


func _clear_list(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()


func _create_objective_row(objective: CampaignObjective) -> Control:
	var label := Label.new()
	label.text = "• %s — %s" % [objective.display_name, objective.description]
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _on_begin() -> void:
	begin_pressed.emit()


func _on_close() -> void:
	closed.emit()
	close()
