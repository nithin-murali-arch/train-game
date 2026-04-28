extends Control

@onready var _faction_panel: FactionSelectPanel = $FactionSelectPanel
@onready var _briefing_panel: BriefingPanel = $BriefingPanel
@onready var _scenario_panel: ScenarioSelectPanel = $ScenarioSelectPanel

var _selected_faction_id: String = ""
var _pending_campaign_id: String = ""
var _pending_scenario_id: String = ""


func _ready() -> void:
	var sandbox_btn := $MarginContainer/VBoxContainer/SandboxButton as Button
	var campaign_btn := $MarginContainer/VBoxContainer/CampaignButton as Button
	var scenario_btn := $MarginContainer/VBoxContainer/ScenarioButton as Button
	var load_btn := $MarginContainer/VBoxContainer/LoadGameButton as Button
	var settings_btn := $MarginContainer/VBoxContainer/SettingsButton as Button
	var credits_btn := $MarginContainer/VBoxContainer/CreditsButton as Button
	var quit_btn := $MarginContainer/VBoxContainer/QuitButton as Button

	if sandbox_btn: sandbox_btn.pressed.connect(_on_sandbox_pressed)
	if campaign_btn: campaign_btn.pressed.connect(_on_campaign_pressed)
	if scenario_btn: scenario_btn.pressed.connect(_on_scenario_pressed)
	if load_btn:
		load_btn.disabled = not SaveLoadService.has_save()
		load_btn.pressed.connect(_on_load_pressed)
	if settings_btn: settings_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menus/settings_shell.tscn"))
	if credits_btn: credits_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menus/credits_shell.tscn"))
	if quit_btn: quit_btn.pressed.connect(func(): get_tree().quit())

	if _faction_panel != null:
		_faction_panel.faction_selected.connect(_on_faction_selected)
		_faction_panel.closed.connect(_show_menu_buttons)

	if _briefing_panel != null:
		_briefing_panel.begin_pressed.connect(_on_begin_pressed)
		_briefing_panel.closed.connect(_show_menu_buttons)

	if _scenario_panel != null:
		_scenario_panel.scenario_selected.connect(_on_scenario_selected)
		_scenario_panel.closed.connect(_show_menu_buttons)


func _on_sandbox_pressed() -> void:
	_store_selection("sandbox", "", "")
	get_tree().change_scene_to_file("res://scenes/game/route_toy_playable.tscn")
	call_deferred("_deferred_start", "sandbox")


func _on_campaign_pressed() -> void:
	_hide_menu_buttons()
	if _faction_panel != null:
		_faction_panel.open()


func _on_scenario_pressed() -> void:
	_hide_menu_buttons()
	if _scenario_panel != null:
		_scenario_panel.open()


func _on_faction_selected(faction_id: String) -> void:
	_selected_faction_id = faction_id
	if _faction_panel != null:
		_faction_panel.close()

	var campaign := BengalRailwayCharter.create_campaign()
	_pending_campaign_id = campaign.campaign_id
	_pending_scenario_id = ""

	if _briefing_panel != null and not campaign.acts.is_empty():
		_briefing_panel.open(campaign.acts[0])


func _on_scenario_selected(scenario_id: String) -> void:
	if _scenario_panel != null:
		_scenario_panel.close()

	_pending_scenario_id = scenario_id
	_pending_campaign_id = ""

	var scenario: ScenarioData = null
	match scenario_id:
		"bengal_charter":
			scenario = Scenarios.create_bengal_charter_scenario()
		"port_monopoly":
			scenario = Scenarios.create_port_monopoly_scenario()
		"monsoon_crisis":
			scenario = Scenarios.create_monsoon_crisis_scenario()

	if _briefing_panel != null and scenario != null:
		_briefing_panel.open_scenario(scenario)


func _on_begin_pressed() -> void:
	if _briefing_panel != null:
		_briefing_panel.close()

	var mode := "sandbox"
	if not _pending_campaign_id.is_empty():
		mode = "campaign"
	elif not _pending_scenario_id.is_empty():
		mode = "scenario"

	_store_selection(mode, _pending_campaign_id, _pending_scenario_id)
	get_tree().change_scene_to_file("res://scenes/game/route_toy_playable.tscn")
	call_deferred("_deferred_start", mode)


func _store_selection(mode: String, campaign_id: String, scenario_id: String) -> void:
	var gs := get_node_or_null("/root/GameState")
	if gs != null:
		gs.set_meta("start_mode", mode)
		gs.set_meta("selected_faction_id", _selected_faction_id)
		gs.set_meta("campaign_id", campaign_id)
		gs.set_meta("scenario_id", scenario_id)


func _deferred_start(mode: String) -> void:
	await get_tree().process_frame
	var root := get_tree().current_scene
	if root == null:
		return
	var route_toy := root as RouteToyPlayable
	if route_toy == null:
		return

	match mode:
		"campaign":
			var campaign_id: String = ""
			var gs := get_node_or_null("/root/GameState")
			if gs != null:
				campaign_id = gs.get_meta("campaign_id", "") as String
			if campaign_id.is_empty():
				campaign_id = "bengal_railway_charter"
			route_toy.start_campaign(campaign_id)
		"scenario":
			var scenario_id: String = ""
			var gs := get_node_or_null("/root/GameState")
			if gs != null:
				scenario_id = gs.get_meta("scenario_id", "") as String
			if scenario_id.is_empty():
				scenario_id = "bengal_charter"
			route_toy.start_scenario(scenario_id)
		"sandbox":
			route_toy.start_sandbox()

	# Bind HUD campaign manager if present
	var hud = route_toy.get_node_or_null("HUD")
	if hud != null and hud.has_method("bind_campaign_manager"):
		if route_toy.campaign_manager != null:
			hud.bind_campaign_manager(route_toy.campaign_manager)
	if hud != null and hud.has_method("bind_route_toy"):
		hud.bind_route_toy(route_toy)


func _on_load_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/route_toy_playable.tscn")
	call_deferred("_deferred_load")


func _deferred_load() -> void:
	var root := get_tree().current_scene
	if root == null:
		return
	var route_toy := root as RouteToyPlayable
	if route_toy != null:
		await get_tree().process_frame
		route_toy.load_game()


func _hide_menu_buttons() -> void:
	var vbox := $MarginContainer/VBoxContainer
	for child in vbox.get_children():
		if child is Button:
			child.visible = false


func _show_menu_buttons() -> void:
	var vbox := $MarginContainer/VBoxContainer
	for child in vbox.get_children():
		if child is Button:
			child.visible = true
