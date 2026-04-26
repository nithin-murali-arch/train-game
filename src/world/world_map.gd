class_name WorldMap
extends Node2D


const TILE_WIDTH := 64
const TILE_HEIGHT := 32

@onready var _terrain_drawer: TerrainDrawer = $TerrainDrawer
@onready var _city_markers: Node2D = $CityMarkers
@onready var _camera: CameraController = $Camera2D

var _loader: RegionLoader
var _region: RegionData


func _ready() -> void:
	_loader = RegionLoader.new("bengal")
	_region = _loader.region

	if _region == null:
		push_error("WorldMap: failed to load Bengal region")
		return

	print("WorldMap: loaded region '%s' with %d cities" % [_region.display_name, _loader.cities.size()])

	_setup_terrain()
	_place_cities()
	_setup_camera()
	_setup_bounds()


func _setup_terrain() -> void:
	_terrain_drawer.setup(_region.map_width, _region.map_height)


func _place_cities() -> void:
	var marker_scene := preload("res://scenes/world/city_marker.tscn")
	for city in _loader.cities:
		var world_pos := grid_to_world(city.map_position)
		var marker: CityMarker = marker_scene.instantiate()
		marker.setup(city, world_pos)
		_city_markers.add_child(marker)
		print("WorldMap: placed city '%s' at grid %s → world %s" % [city.display_name, city.map_position, world_pos])


func _setup_camera() -> void:
	var start_city := _loader.catalog.get_city_by_id(_region.starting_city_id)
	if start_city != null:
		_camera.position = grid_to_world(start_city.map_position)
	else:
		_camera.position = grid_to_world(Vector2i(_region.map_width / 2, _region.map_height / 2))


func _setup_bounds() -> void:
	# Isometric projection: grid corners map to a diamond in world space.
	# We must sample all four corners to find the true bounding box.
	var corners := [
		grid_to_world(Vector2i(0, 0)),
		grid_to_world(Vector2i(_region.map_width, 0)),
		grid_to_world(Vector2i(0, _region.map_height)),
		grid_to_world(Vector2i(_region.map_width, _region.map_height)),
	]
	var min_x: float = corners[0].x
	var min_y: float = corners[0].y
	var max_x: float = corners[0].x
	var max_y: float = corners[0].y
	for c in corners:
		min_x = minf(min_x, c.x)
		min_y = minf(min_y, c.y)
		max_x = maxf(max_x, c.x)
		max_y = maxf(max_y, c.y)
	var bounds := Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))
	bounds = bounds.grow(300)
	_camera.set_bounds(bounds)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_G:
			_terrain_drawer.show_grid = not _terrain_drawer.show_grid
			_terrain_drawer.queue_redraw()


static func grid_to_world(grid: Vector2i) -> Vector2:
	var wx := (grid.x - grid.y) * (TILE_WIDTH / 2)
	var wy := (grid.x + grid.y) * (TILE_HEIGHT / 2)
	return Vector2(wx, wy)


static func world_to_grid(world: Vector2) -> Vector2i:
	var sum := world.y / (TILE_HEIGHT / 2.0)
	var diff := world.x / (TILE_WIDTH / 2.0)
	var gx := int(roundf((sum + diff) / 2.0))
	var gy := int(roundf((sum - diff) / 2.0))
	return Vector2i(gx, gy)
