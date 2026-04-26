extends Node

const SAVE_VERSION := "0.1"

var treasury: int = 20000
var current_day: int = 0
var game_speed: float = 1.0
var is_paused: bool = false

func _ready() -> void:
    print("GameState initialized. Treasury: ₹", treasury)
