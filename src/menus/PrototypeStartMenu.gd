extends Control

func _ready() -> void:
	var begin_btn := $CenterContainer/PanelContainer/VBoxContainer/BeginButton as Button
	var back_btn := $CenterContainer/PanelContainer/VBoxContainer/BackButton as Button
	
	if begin_btn: begin_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/game/route_toy_playable.tscn"))
	if back_btn: back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn"))
