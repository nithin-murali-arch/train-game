class_name TerrainProfileEntryData
extends Resource

@export var terrain_id: String = ""
@export var weight: float = 1.0
@export var construction_cost_multiplier: float = 1.0
@export var movement_cost_multiplier: float = 1.0
@export var flood_risk: float = 0.0

func validate() -> Array[String]:
    var errors: Array[String] = []

    if terrain_id.strip_edges().is_empty():
        errors.append("terrain_id is required")
    elif terrain_id != terrain_id.to_snake_case():
        errors.append("terrain_id must be lowercase snake_case: " + terrain_id)

    if weight < 0.0:
        errors.append("weight must be non-negative")

    if construction_cost_multiplier <= 0.0:
        errors.append("construction_cost_multiplier must be greater than zero")

    if movement_cost_multiplier <= 0.0:
        errors.append("movement_cost_multiplier must be greater than zero")

    if flood_risk < 0.0 or flood_risk > 1.0:
        errors.append("flood_risk must be between 0 and 1")

    return errors
