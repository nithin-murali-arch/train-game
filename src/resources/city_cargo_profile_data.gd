class_name CityCargoProfileData
extends Resource

@export var cargo_id: String = ""
@export var production_per_day: int = 0
@export var demand_per_day: int = 0
@export var starting_stock: int = 0

@export var min_stock: int = 0
@export var target_stock: int = 0
@export var max_stock: int = 100000

@export var price_elasticity: float = 1.0
@export var import_priority: float = 1.0
@export var export_priority: float = 1.0

@export var is_enabled: bool = true

func validate() -> Array[String]:
    var errors: Array[String] = []

    if cargo_id.strip_edges().is_empty():
        errors.append("cargo_id is required")
    elif cargo_id != cargo_id.to_snake_case():
        errors.append("cargo_id must be lowercase snake_case: " + cargo_id)

    if production_per_day < 0:
        errors.append("production_per_day must be non-negative")

    if demand_per_day < 0:
        errors.append("demand_per_day must be non-negative")

    if starting_stock < 0:
        errors.append("starting_stock must be non-negative")

    if min_stock < 0:
        errors.append("min_stock must be non-negative")

    if target_stock < 0:
        errors.append("target_stock must be non-negative")

    if max_stock < 0:
        errors.append("max_stock must be non-negative")

    if min_stock > max_stock:
        errors.append("min_stock cannot exceed max_stock")

    if target_stock > max_stock:
        errors.append("target_stock cannot exceed max_stock")

    if price_elasticity <= 0.0:
        errors.append("price_elasticity must be greater than zero")

    if import_priority < 0.0:
        errors.append("import_priority must be non-negative")

    if export_priority < 0.0:
        errors.append("export_priority must be non-negative")

    return errors
