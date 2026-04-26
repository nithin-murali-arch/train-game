extends Control

func _ready() -> void:
	var continue_btn := $CenterContainer/VBoxContainer/ContinueButton as Button
	if continue_btn:
		continue_btn.pressed.connect(_on_continue_pressed)

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
