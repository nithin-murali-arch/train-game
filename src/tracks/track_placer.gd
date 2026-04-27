class_name TrackPlacer
extends Node


@export var map_width: int = 64
@export var map_height: int = 64
@export var base_cost_per_km: float = 500.0
@export var removal_threshold_px: float = 20.0
@export var city_snap_radius_px: float = 32.0

var _graph: TrackGraph
var _camera: Camera2D
var _preview: TrackPlacementPreview
var _renderer: TrackRenderer
var _treasury: TreasuryState
var _state := "IDLE"
var _start_coord: Vector2i
var _last_placed_edge: Array[Vector2i] = []
var _build_mode_active: bool = false
var _city_coords: Array[Vector2i] = []
var _on_toast: Callable
var _owner_faction_id: String = "player_railway_company"


func setup(graph: TrackGraph, camera: Camera2D, preview: TrackPlacementPreview, renderer: TrackRenderer) -> void:
	_graph = graph
	_camera = camera
	_preview = preview
	_renderer = renderer


func set_build_mode(active: bool) -> void:
	_build_mode_active = active
	if not active:
		_cancel()


func set_treasury(treasury: TreasuryState) -> void:
	_treasury = treasury


func set_city_coords(coords: Array[Vector2i]) -> void:
	_city_coords = coords


func set_on_toast(callback: Callable) -> void:
	_on_toast = callback


func set_owner_faction_id(faction_id: String) -> void:
	_owner_faction_id = faction_id


func _process(_delta: float) -> void:
	if _state == "SELECTING_END":
		var hover := _mouse_to_grid()
		_preview.update_preview(_start_coord, hover, _is_valid_placement(_start_coord, hover))


func _unhandled_input(event: InputEvent) -> void:
	if not _build_mode_active:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_cancel()
			return
		if event.keycode == KEY_X:
			_remove_last_edge()
			return

	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if Input.is_key_pressed(KEY_SHIFT):
					_remove_nearest_edge()
				elif _state == "IDLE":
					_select_start()
				else:
					_place_edge()
			MOUSE_BUTTON_RIGHT:
				_cancel()


# ============================================================================
# Placement actions
# ============================================================================

func _select_start() -> void:
	var grid := _mouse_to_grid()
	if not _is_in_bounds(grid):
		print("TRACK PLACEMENT: start out of bounds")
		return
	_start_coord = grid
	_state = "SELECTING_END"
	print("TRACK PLACEMENT: selected start %s" % _start_coord)


func _place_edge() -> void:
	var end_coord := _mouse_to_grid()

	if not _is_in_bounds(end_coord):
		_show_toast("Track placement out of bounds")
		_cancel()
		return

	if not _is_valid_placement(_start_coord, end_coord):
		_cancel()
		return

	var length_km := _start_coord.distance_to(end_coord)
	var cost := int(roundf(length_km * base_cost_per_km))

	if _treasury != null and not _treasury.can_afford(cost):
		_show_toast("Insufficient funds — need ₹%s" % _comma_sep(cost))
		_cancel()
		return

	var added := _graph.add_edge(_start_coord, end_coord, _owner_faction_id)
	if added:
		if _treasury != null:
			_treasury.spend(cost)
		_last_placed_edge = [_start_coord, end_coord]
		_show_toast("Track built: ₹%s" % _comma_sep(cost))
		print("TRACK PLACEMENT")
		print("  Start: %s" % _start_coord)
		print("  End: %s" % end_coord)
		print("  Length: %.1f km" % length_km)
		print("  Cost: ₹%d" % cost)
		print("  Edge added: true")
		_validate_and_print()
		_renderer.queue_redraw()
	else:
		_show_toast("Track placement failed")
		print("TRACK PLACEMENT: rejected by graph")

	_cancel()


func _cancel() -> void:
	_state = "IDLE"
	_preview.clear()


# ============================================================================
# Removal actions
# ============================================================================

func _remove_last_edge() -> void:
	if _last_placed_edge.is_empty():
		print("TRACK PLACEMENT: no edge to remove")
		return
	var from := _last_placed_edge[0]
	var to := _last_placed_edge[1]
	var removed := _graph.remove_edge(from, to)
	if removed:
		print("TRACK PLACEMENT: removed last edge %s -> %s" % [from, to])
		_validate_and_print()
		_renderer.queue_redraw()
	_last_placed_edge.clear()


func _remove_nearest_edge() -> void:
	var mouse_world := _camera.get_global_mouse_position()
	var closest_edge: TrackEdgeData = null
	var closest_dist := INF

	for edge in _graph.get_all_edges():
		var from_world := WorldMap.grid_to_world(edge.from_coord)
		var to_world := WorldMap.grid_to_world(edge.to_coord)
		var dist := _point_to_segment_distance(mouse_world, from_world, to_world)
		if dist < closest_dist:
			closest_dist = dist
			closest_edge = edge

	var threshold := removal_threshold_px / _camera.zoom.x
	if closest_edge != null and closest_dist <= threshold:
		var removed := _graph.remove_edge(closest_edge.from_coord, closest_edge.to_coord)
		if removed:
			print("TRACK PLACEMENT: removed edge %s -> %s (distance %.1f px)" % [closest_edge.from_coord, closest_edge.to_coord, closest_dist])
			_validate_and_print()
			_renderer.queue_redraw()
	else:
		print("TRACK PLACEMENT: no edge near click")


# ============================================================================
# Validation helpers
# ============================================================================

func _is_valid_placement(start: Vector2i, end: Vector2i) -> bool:
	if start == end:
		print("TRACK PLACEMENT: rejected — start and end cannot be the same")
		return false
	if not _is_in_bounds(start) or not _is_in_bounds(end):
		print("TRACK PLACEMENT: rejected — out of bounds")
		return false
	if _graph.has_edge(start, end):
		print("TRACK PLACEMENT: rejected — edge already exists")
		return false
	return true


func _is_in_bounds(grid: Vector2i) -> bool:
	return grid.x >= 0 and grid.y >= 0 and grid.x < map_width and grid.y < map_height


func _validate_and_print() -> void:
	var errors := _graph.validate()
	if errors.is_empty():
		print("  TrackGraph validation: PASS")
	else:
		print("  TrackGraph validation: FAIL")
		for err in errors:
			print("    - %s" % err)


# ============================================================================
# Coordinate helpers
# ============================================================================

func _mouse_to_grid() -> Vector2i:
	var world_pos := _camera.get_global_mouse_position()
	var grid := WorldMap.world_to_grid(world_pos)

	# Snap to nearest city if within radius
	if not _city_coords.is_empty():
		var best_dist := INF
		var best_coord := grid
		for city_coord in _city_coords:
			var city_world := WorldMap.grid_to_world(city_coord)
			var dist := world_pos.distance_to(city_world)
			if dist < best_dist:
				best_dist = dist
				best_coord = city_coord
		if best_dist <= city_snap_radius_px:
			return best_coord

	return grid


func _show_toast(message: String) -> void:
	if _on_toast.is_valid():
		_on_toast.call(message)
	else:
		print("Toast: %s" % message)


static func _comma_sep(n: int) -> String:
	var s := str(n)
	var result := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result


static func _point_to_segment_distance(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var ap := p - a
	var ab_len_sq := ab.length_squared()
	if ab_len_sq < 0.0001:
		return ap.length()
	var t := clampf(ap.dot(ab) / ab_len_sq, 0.0, 1.0)
	var closest := a + ab * t
	return p.distance_to(closest)
