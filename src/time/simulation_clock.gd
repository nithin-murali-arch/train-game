class_name SimulationClock
extends Node


signal day_passed(day: int, month: int, year: int)

var current_day: int = 1
var current_month: int = 1
var current_year: int = 1857
var is_paused: bool = true
var days_per_real_second: float = 2.0

var _accumulator: float = 0.0


func start() -> void:
	is_paused = false


func pause() -> void:
	is_paused = true


func resume() -> void:
	is_paused = false


func set_speed(p_days_per_real_second: float) -> void:
	days_per_real_second = maxf(p_days_per_real_second, 0.1)


func advance_one_day() -> void:
	_advance_one_day()


func get_date_string() -> String:
	return "%d/%d/%d" % [current_day, current_month, current_year]


func _process(delta: float) -> void:
	if is_paused:
		return
	if days_per_real_second <= 0.0:
		return

	_accumulator += delta
	var threshold := 1.0 / days_per_real_second
	while _accumulator >= threshold:
		_accumulator -= threshold
		_advance_one_day()


func _advance_one_day() -> void:
	current_day += 1
	if current_day > 30:
		current_day = 1
		current_month += 1
		if current_month > 12:
			current_month = 1
			current_year += 1

	day_passed.emit(current_day, current_month, current_year)
