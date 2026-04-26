extends Node

@export var ticks_per_day: int = 24

var _tick_counter: int = 0

func _ready() -> void:
    print("EconomyManager initialized")

func _process(delta: float) -> void:
    if GameState.is_paused:
        return
    _tick_counter += 1
    if _tick_counter >= ticks_per_day:
        _tick_counter = 0
        _tick_day()

func _tick_day() -> void:
    GameState.current_day += 1
    EventBus.economy_tick.emit(GameState.current_day)
