class_name TrainData
extends Resource

@export var train_id: String = ""
@export var display_name: String = ""
@export var description: String = ""

@export var cost: int = 0
@export var speed_km_per_tick: float = 1.0
@export var capacity_tons: int = 0
@export var maintenance_per_day: int = 0

@export var train_tags: Array[String] = []
@export var sprite: Texture2D

func validate() -> Array[String]:
    var errors: Array[String] = []

    if train_id.strip_edges().is_empty():
        errors.append("train_id is required")
    elif train_id != train_id.to_snake_case():
        errors.append("train_id must be lowercase snake_case: " + train_id)

    if display_name.strip_edges().is_empty():
        errors.append("display_name is required")

    if cost < 0:
        errors.append("cost must be non-negative")

    if speed_km_per_tick <= 0.0:
        errors.append("speed_km_per_tick must be greater than zero")

    if capacity_tons <= 0:
        errors.append("capacity_tons must be greater than zero")

    if maintenance_per_day < 0:
        errors.append("maintenance_per_day must be non-negative")

    for tag in train_tags:
        if tag.strip_edges().is_empty():
            errors.append("train_tags contains empty string")
            break

    return errors
