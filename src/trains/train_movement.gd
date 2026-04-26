class_name TrainMovement
extends Node


signal segment_started(from_coord: Vector2i, to_coord: Vector2i)
signal segment_arrived(coord: Vector2i)
signal destination_arrived(coord: Vector2i)
signal movement_failed(reason: String)


## Debug speed in world pixels per second. Future sprints will replace this
## with a mapping from TrainData.speed_km_per_tick to simulation speed.
const DEFAULT_SPEED_PX_PER_SEC: float = 80.0

var _path: Array[Vector2i] = []
var _segment_index: int = 0
var _segment_progress: float = 0.0
var _speed: float = DEFAULT_SPEED_PX_PER_SEC
var _is_moving: bool = false
var _grid_to_world: Callable


func setup(grid_to_world_fn: Callable, speed: float = DEFAULT_SPEED_PX_PER_SEC) -> void:
	_grid_to_world = grid_to_world_fn
	_speed = speed


func set_path(path: Array[Vector2i]) -> bool:
	if path.is_empty():
		movement_failed.emit("empty path")
		return false

	_path = path.duplicate()
	_segment_index = 0
	_segment_progress = 0.0
	_is_moving = false
	return true


func start() -> void:
	if _path.is_empty():
		movement_failed.emit("cannot start with empty path")
		return

	# Single-coordinate path (start == destination): immediate arrival
	if _path.size() == 1:
		var coord: Vector2i = _path[0]
		_snap_to_coord(coord)
		destination_arrived.emit(coord)
		return

	_is_moving = true
	var from_coord: Vector2i = _path[_segment_index]
	var to_coord: Vector2i = _path[_segment_index + 1]
	segment_started.emit(from_coord, to_coord)


func stop() -> void:
	_is_moving = false


func reset() -> void:
	stop()
	_path.clear()
	_segment_index = 0
	_segment_progress = 0.0


func is_moving() -> bool:
	return _is_moving


func get_current_coord() -> Vector2i:
	if _path.is_empty():
		return Vector2i.ZERO
	return _path[_segment_index]


func _process(delta: float) -> void:
	if not _is_moving or _path.is_empty():
		return

	# Guard against single-coord path
	if _path.size() < 2:
		return

	if _segment_index >= _path.size() - 1:
		# Already at or past final segment
		_is_moving = false
		return

	var from_coord: Vector2i = _path[_segment_index]
	var to_coord: Vector2i = _path[_segment_index + 1]
	var from_world: Vector2 = _grid_to_world.call(from_coord)
	var to_world: Vector2 = _grid_to_world.call(to_coord)

	var segment_length: float = from_world.distance_to(to_world)
	if segment_length < 0.0001:
		segment_length = 0.0001

	_segment_progress += (_speed * delta) / segment_length

	# Clamp and compute position
	var clamped_progress: float = clampf(_segment_progress, 0.0, 1.0)
	var interpolated: Vector2 = from_world.lerp(to_world, clamped_progress)
	get_parent().position = interpolated

	# Rotate parent to face movement direction
	var direction: Vector2 = (to_world - from_world).normalized()
	if direction.length_squared() > 0.0001:
		get_parent().rotation = direction.angle()

	if _segment_progress >= 1.0:
		# Arrived at end of current segment
		segment_arrived.emit(to_coord)
		_segment_index += 1
		_segment_progress = 0.0

		if _segment_index >= _path.size() - 1:
			# Reached destination
			_is_moving = false
			destination_arrived.emit(_path[_path.size() - 1])
		else:
			# Start next segment
			var next_from: Vector2i = _path[_segment_index]
			var next_to: Vector2i = _path[_segment_index + 1]
			segment_started.emit(next_from, next_to)


func _snap_to_coord(coord: Vector2i) -> void:
	var world_pos: Vector2 = _grid_to_world.call(coord)
	get_parent().position = world_pos
