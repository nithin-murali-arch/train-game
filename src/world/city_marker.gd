class_name CityMarker
extends Node2D


const ROLE_COLORS := {
	"Port Metropolis": Color("#D4A04A"),
	"Industrial City": Color("#7A8FA3"),
	"Mining Center": Color("#5A5A5A"),
	"Agricultural Town": Color("#7A9B5C"),
}

var _tex_small: Texture2D
var _tex_medium: Texture2D
var _tex_large: Texture2D
var _tex_small_port: Texture2D
var _tex_medium_port: Texture2D
var _tex_large_port: Texture2D


func _ready() -> void:
	_tex_small = _try_load("res://assets/generated/city_small.png")
	_tex_medium = _try_load("res://assets/generated/city_medium.png")
	_tex_large = _try_load("res://assets/generated/city_large.png")
	_tex_small_port = _try_load("res://assets/generated/city_small_port.png")
	_tex_medium_port = _try_load("res://assets/generated/city_medium_port.png")
	_tex_large_port = _try_load("res://assets/generated/city_large_port.png")


func _try_load(path: String) -> Texture2D:
	var tex := load(path) as Texture2D
	return tex


func setup(city_data: CityData, world_pos: Vector2) -> void:
	position = world_pos

	var sprite: Sprite2D = $Sprite2D
	var label: Label = $Label

	var tex := _get_city_texture(city_data)
	if tex != null and sprite != null:
		sprite.texture = tex
		sprite.modulate = Color.WHITE
	else:
		# Fallback: tint with role color
		if sprite != null:
			sprite.modulate = ROLE_COLORS.get(city_data.role, Color("#D4A04A"))

	label.text = city_data.display_name


func _get_city_texture(city_data: CityData) -> Texture2D:
	var is_port := city_data.role.find("Port") >= 0
	var tier := city_data.population_tier

	if is_port:
		match tier:
			"small":
				return _tex_small_port
			"medium":
				return _tex_medium_port
			"large":
				return _tex_large_port
	else:
		match tier:
			"small":
				return _tex_small
			"medium":
				return _tex_medium
			"large":
				return _tex_large

	return _tex_medium
