class_name TrackPlacementPreview
extends Node2D


@export var valid_color: Color = Color("#4A9B4A")
@export var invalid_color: Color = Color("#B44A4A")
@export var preview_width: float = 2.0

var _start: Vector2i
var _end: Vector2i
var _is_valid: bool = false
var _show: bool = false


func update_preview(start: Vector2i, end: Vector2i, is_valid: bool) -> void:
	_start = start
	_end = end
	_is_valid = is_valid
	_show = true
	queue_redraw()


func clear() -> void:
	_show = false
	queue_redraw()


func _draw() -> void:
	if not _show:
		return

	var color := valid_color if _is_valid else invalid_color
	var from_world := WorldMap.grid_to_world(_start)
	var to_world := WorldMap.grid_to_world(_end)
	draw_line(from_world, to_world, color, preview_width, true)

	# Debug label: length and estimated cost
	var mid := (from_world + to_world) / 2.0
	var length_km := _start.distance_to(_end)
	var cost := length_km * 500.0
	var label := "%.1f km | ₹%.0f" % [length_km, cost]
	var font := ThemeDB.fallback_font
	draw_string(font, mid + Vector2(0, -12), label, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, color)
