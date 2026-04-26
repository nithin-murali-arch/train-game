class_name CityMarker
extends Node2D


const ROLE_COLORS := {
	"Port Metropolis": Color("#D4A04A"),
	"Industrial City": Color("#7A8FA3"),
	"Mining Center": Color("#5A5A5A"),
	"Agricultural Town": Color("#7A9B5C"),
}


func setup(city_data: CityData, world_pos: Vector2) -> void:
	position = world_pos

	var polygon: Polygon2D = $Polygon2D
	var label: Label = $Label

	polygon.color = ROLE_COLORS.get(city_data.role, Color("#D4A04A"))
	label.text = city_data.display_name
