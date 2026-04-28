class_name TrainEntity
extends Node2D


@export var train_data: TrainData
@export var train_id: String = "debug_train"
@export var display_name: String = "Debug Train"
@export var instance_id: String = ""  # Stable runtime instance ID (train_001, etc.)

var _movement: TrainMovement
var _cargo: TrainCargo
var _pathfinder: TrainPathfinder

var _tex_freight_nw: Texture2D
var _tex_freight_ne: Texture2D
var _tex_freight_sw: Texture2D
var _tex_freight_se: Texture2D
var _tex_mixed_nw: Texture2D
var _tex_mixed_ne: Texture2D
var _tex_mixed_sw: Texture2D
var _tex_mixed_se: Texture2D


func _ready() -> void:
	_movement = $TrainMovement as TrainMovement
	if _movement == null:
		push_error("TrainEntity: TrainMovement child not found")
		return

	_cargo = $TrainCargo as TrainCargo
	if _cargo == null:
		push_error("TrainEntity: TrainCargo child not found")
		return

	# Connect movement signals for debug output (idempotent via _ensure_connected)
	_ensure_connected(_movement.segment_started, _on_segment_started)
	_ensure_connected(_movement.segment_arrived, _on_segment_arrived)
	_ensure_connected(_movement.destination_arrived, _on_destination_arrived)
	_ensure_connected(_movement.movement_failed, _on_movement_failed)

	# Draw on the trains render layer
	set_visibility_layer_bit(3, true)

	_load_textures()


func _load_textures() -> void:
	_tex_freight_nw = _try_load("res://assets/generated/train_freight_NW.png")
	_tex_freight_ne = _try_load("res://assets/generated/train_freight_NE.png")
	_tex_freight_sw = _try_load("res://assets/generated/train_freight_SW.png")
	_tex_freight_se = _try_load("res://assets/generated/train_freight_SE.png")
	_tex_mixed_nw = _try_load("res://assets/generated/train_mixed_NW.png")
	_tex_mixed_ne = _try_load("res://assets/generated/train_mixed_NE.png")
	_tex_mixed_sw = _try_load("res://assets/generated/train_mixed_SW.png")
	_tex_mixed_se = _try_load("res://assets/generated/train_mixed_SE.png")


func _try_load(path: String) -> Texture2D:
	var tex := load(path) as Texture2D
	return tex


func _ensure_connected(sig: Signal, callable: Callable) -> void:
	if not sig.is_connected(callable):
		sig.connect(callable)


func setup(train_data_res: TrainData, pathfinder: TrainPathfinder) -> void:
	train_data = train_data_res
	_pathfinder = pathfinder

	if train_data != null:
		train_id = train_data.train_id
		display_name = train_data.display_name

	if _movement == null:
		_movement = $TrainMovement as TrainMovement
		if _movement == null:
			push_error("TrainEntity: TrainMovement child not found")
			return
		_ensure_connected(_movement.segment_started, _on_segment_started)
		_ensure_connected(_movement.segment_arrived, _on_segment_arrived)
		_ensure_connected(_movement.destination_arrived, _on_destination_arrived)
		_ensure_connected(_movement.movement_failed, _on_movement_failed)

	if _cargo == null:
		_cargo = $TrainCargo as TrainCargo
		if _cargo == null:
			push_error("TrainEntity: TrainCargo child not found")
			return

	_movement.setup(Callable(WorldMap, "grid_to_world"))


func set_route(start: Vector2i, end: Vector2i) -> bool:
	if _pathfinder == null:
		push_error("TrainEntity: pathfinder not set")
		return false

	var result: TrackPathResult = _pathfinder.find_path(start, end)
	if not result.success:
		print("TRAIN ROUTE FAILED: %s -> %s (%s)" % [start, end, result.error_message])
		return false

	reset_to(start)
	var ok := _movement.set_path(result.coords)
	if ok:
		print("TRAIN ROUTE: %s -> %s | %d coords | %.1f km" % [start, end, result.coords.size(), result.total_length_km])
	return ok


func start_movement() -> void:
	_movement.start()


func reset_to(coord: Vector2i) -> void:
	_movement.reset()
	var world_pos: Vector2 = WorldMap.grid_to_world(coord)
	position = world_pos
	rotation = 0.0


func get_train_cargo() -> TrainCargo:
	return _cargo


func is_moving() -> bool:
	return _movement.is_moving()


func _draw() -> void:
	var tex := _get_facing_texture()
	if tex != null:
		var tex_size := tex.get_size()
		draw_texture(tex, -tex_size / 2.0)
	else:
		# Simple placeholder train visual: a small arrow shape
		var color := Color("#8B4513")
		if train_data != null and train_data.sprite != null:
			# Future: draw sprite
			pass

		var size := Vector2(14.0, 8.0)
		var points: PackedVector2Array = PackedVector2Array([
			Vector2(size.x * 0.5, 0.0),
			Vector2(-size.x * 0.5, size.y * 0.5),
			Vector2(-size.x * 0.3, 0.0),
			Vector2(-size.x * 0.5, -size.y * 0.5),
		])
		draw_colored_polygon(points, color)


func _get_facing_texture() -> Texture2D:
	if train_data == null:
		return null

	var is_freight := train_data.train_id.begins_with("freight")
	var is_mixed := train_data.train_id.begins_with("mixed")
	if not is_freight and not is_mixed:
		return null

	var angle := rotation
	# Normalize angle to [-PI, PI]
	while angle > PI:
		angle -= 2.0 * PI
	while angle < -PI:
		angle += 2.0 * PI

	var dir_tex: Texture2D
	if angle > -PI / 2.0 and angle <= 0.0:
		dir_tex = _tex_freight_ne if is_freight else _tex_mixed_ne
	elif angle > 0.0 and angle <= PI / 2.0:
		dir_tex = _tex_freight_se if is_freight else _tex_mixed_se
	elif angle > PI / 2.0 and angle <= PI:
		dir_tex = _tex_freight_sw if is_freight else _tex_mixed_sw
	else:
		dir_tex = _tex_freight_nw if is_freight else _tex_mixed_nw

	return dir_tex


func _on_segment_started(from_coord: Vector2i, to_coord: Vector2i) -> void:
	print("Segment started: %s -> %s" % [from_coord, to_coord])


func _on_segment_arrived(coord: Vector2i) -> void:
	print("Arrived segment: %s" % coord)


func _on_destination_arrived(coord: Vector2i) -> void:
	print("Destination arrived: %s" % coord)


func _on_movement_failed(reason: String) -> void:
	print("Movement failed: %s" % reason)
