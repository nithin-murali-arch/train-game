class_name TrainEntity
extends Node2D


@export var train_data: TrainData
@export var train_id: String = "debug_train"
@export var display_name: String = "Debug Train"

var _movement: TrainMovement
var _cargo: TrainCargo
var _pathfinder: TrainPathfinder


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


func _on_segment_started(from_coord: Vector2i, to_coord: Vector2i) -> void:
	print("Segment started: %s -> %s" % [from_coord, to_coord])


func _on_segment_arrived(coord: Vector2i) -> void:
	print("Arrived segment: %s" % coord)


func _on_destination_arrived(coord: Vector2i) -> void:
	print("Destination arrived: %s" % coord)


func _on_movement_failed(reason: String) -> void:
	print("Movement failed: %s" % reason)
