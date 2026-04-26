extends Node2D

const WORLD_SCENE := preload("res://scenes/world/world.tscn")

func _ready() -> void:
	var world := WORLD_SCENE.instantiate()
	add_child(world)
