class_name CameraController
extends Camera2D


@export var pan_speed: float = 600.0
@export var zoom_speed: float = 0.15
@export var min_zoom: float = 0.5
@export var max_zoom: float = 4.0

var _is_panning: bool = false
var _last_mouse_pos: Vector2
var _map_bounds: Rect2 = Rect2()


func set_bounds(bounds: Rect2) -> void:
	_map_bounds = bounds


func _process(delta: float) -> void:
	# Keyboard pan (WASD / arrow keys)
	var pan_input := Input.get_vector(
		"camera_pan_left", "camera_pan_right",
		"camera_pan_up", "camera_pan_down"
	)
	if pan_input != Vector2.ZERO:
		position += pan_input * pan_speed * delta / zoom.x

	# Middle-click drag pan
	if _is_panning:
		var current_mouse := get_global_mouse_position()
		var delta_pos := _last_mouse_pos - current_mouse
		position += delta_pos
		_last_mouse_pos = get_global_mouse_position()

	# Clamp to map bounds
	if _map_bounds.has_area():
		position.x = clamp(position.x, _map_bounds.position.x, _map_bounds.end.x)
		position.y = clamp(position.y, _map_bounds.position.y, _map_bounds.end.y)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_MIDDLE:
				_is_panning = event.pressed
				if _is_panning:
					_last_mouse_pos = get_global_mouse_position()
			MOUSE_BUTTON_WHEEL_UP:
				if event.pressed:
					_apply_zoom(zoom_speed)
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed:
					_apply_zoom(-zoom_speed)


func _apply_zoom(amount: float) -> void:
	var new_zoom := clampf(zoom.x + amount, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)
