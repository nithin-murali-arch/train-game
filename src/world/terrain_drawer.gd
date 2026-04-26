class_name TerrainDrawer
extends Node2D


@export var tile_width: int = 64
@export var tile_height: int = 32
@export var show_grid: bool = false

@export var color_plains: Color = Color("#C4A882")
@export var color_river: Color = Color("#6B9B8A")
@export var color_wetland: Color = Color("#7A9B6B")
@export var color_forest: Color = Color("#7A8B5C")
@export var color_hills: Color = Color("#8B7355")

var _map_width: int = 64
var _map_height: int = 64


func setup(width: int, height: int) -> void:
	_map_width = width
	_map_height = height
	queue_redraw()


func _draw() -> void:
	for y in range(_map_height):
		for x in range(_map_width):
			var world_pos := _grid_to_world(Vector2i(x, y))
			var color := _get_terrain_color(x, y)
			_draw_diamond(world_pos, color)
			if show_grid:
				_draw_grid_outline(world_pos)


func _grid_to_world(grid: Vector2i) -> Vector2:
	var wx := (grid.x - grid.y) * (tile_width / 2)
	var wy := (grid.x + grid.y) * (tile_height / 2)
	return Vector2(wx, wy)


func _draw_diamond(center: Vector2, color: Color) -> void:
	var half_w := tile_width / 2.0
	var half_h := tile_height / 2.0
	var points := PackedVector2Array([
		Vector2(center.x, center.y - half_h),
		Vector2(center.x + half_w, center.y),
		Vector2(center.x, center.y + half_h),
		Vector2(center.x - half_w, center.y)
	])
	draw_colored_polygon(points, color)


func _draw_grid_outline(center: Vector2, outline_color: Color = Color("#00000022")) -> void:
	var half_w := tile_width / 2.0
	var half_h := tile_height / 2.0
	var points := PackedVector2Array([
		Vector2(center.x, center.y - half_h),
		Vector2(center.x + half_w, center.y),
		Vector2(center.x, center.y + half_h),
		Vector2(center.x - half_w, center.y),
		Vector2(center.x, center.y - half_h)
	])
	draw_polyline(points, outline_color, 1.0, true)


## Hand-authored, geography-informed Bengal terrain.
## No procedural generation. No terrain_seed usage.
func _get_terrain_color(gx: int, gy: int) -> Color:
	var in_river := false

	# Main Ganges channel: narrow diagonal from NW toward SE
	if gy >= 5 and gy <= 30:
		var expected_x := 12.0 + (gy - 5) * 0.35
		if absf(gx - expected_x) <= 2.5:
			in_river = true

	# Delta fan: widening toward the south
	if gy > 30 and gy <= 55:
		var expected_x := 21.0 + (gy - 30) * 0.2
		var width := 3.0 + (gy - 30) * 0.15
		if absf(gx - expected_x) <= width:
			in_river = true

	# Hooghly branch: westward toward Kolkata
	if gx >= 8 and gx <= 18 and gy >= 10 and gy <= 28:
		var expected_y := 10.0 + (gx - 8) * 1.2
		if absf(gy - expected_y) <= 2.5:
			in_river = true

	if in_river:
		return color_river

	# Sundarbans wetland hint: south-west corner
	if gx <= 10 and gy >= 45:
		return color_wetland

	# Forest clusters: hand-placed fixed regions
	if (gx >= 20 and gx <= 28 and gy >= 6 and gy <= 12) or \
	   (gx >= 45 and gx <= 52 and gy >= 15 and gy <= 22):
		return color_forest

	# Hill traces: far north-east (Himalayan foothills suggestion)
	if gx >= 40 and gy <= 8:
		return color_hills

	return color_plains
