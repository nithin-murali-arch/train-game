extends Control

func _ready() -> void:
	var new_game_btn := $MarginContainer/VBoxContainer/NewGameButton as Button
	var load_btn := $MarginContainer/VBoxContainer/LoadGameButton as Button
	var settings_btn := $MarginContainer/VBoxContainer/SettingsButton as Button
	var credits_btn := $MarginContainer/VBoxContainer/CreditsButton as Button
	var quit_btn := $MarginContainer/VBoxContainer/QuitButton as Button
	
	if new_game_btn: new_game_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menus/prototype_start_menu.tscn"))
	if load_btn:
		load_btn.disabled = not SaveLoadService.has_save()
		load_btn.pressed.connect(_on_load_pressed)
	if settings_btn: settings_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menus/settings_shell.tscn"))
	if credits_btn: credits_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menus/credits_shell.tscn"))
	if quit_btn: quit_btn.pressed.connect(func(): get_tree().quit())


func _on_load_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/route_toy_playable.tscn")
	# Defer load until scene is ready; RouteToyPlayable will auto-detect and load
	call_deferred("_deferred_load")


func _deferred_load() -> void:
	var root := get_tree().current_scene
	if root == null:
		return
	var route_toy := root as RouteToyPlayable
	if route_toy != null:
		# Wait one frame for _ready() to complete
		await get_tree().process_frame
		route_toy.load_game()
