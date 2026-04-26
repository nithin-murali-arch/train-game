extends Control

func _ready() -> void:
	var back_btn := $MarginContainer/VBoxContainer/BackButton as Button
	if back_btn: back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn"))
