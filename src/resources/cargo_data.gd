class_name CargoData
extends Resource

@export var cargo_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var category: String = "bulk"

@export var base_price: float = 1.0
@export var weight_per_unit: float = 1.0
@export var volume_per_unit: float = 1.0

@export var compatible_train_tags: Array[String] = []
@export var is_passenger: bool = false
@export var icon: Texture2D

func validate() -> Array[String]:
    var errors: Array[String] = []

    if cargo_id.strip_edges().is_empty():
        errors.append("cargo_id is required")
    elif cargo_id != cargo_id.to_snake_case():
        errors.append("cargo_id must be lowercase snake_case: " + cargo_id)

    if display_name.strip_edges().is_empty():
        errors.append("display_name is required")

    if category.strip_edges().is_empty():
        errors.append("category is required")

    if base_price <= 0.0:
        errors.append("base_price must be greater than zero")

    if weight_per_unit <= 0.0:
        errors.append("weight_per_unit must be greater than zero")

    if volume_per_unit < 0.0:
        errors.append("volume_per_unit must be non-negative")

    for tag in compatible_train_tags:
        if tag.strip_edges().is_empty():
            errors.append("compatible_train_tags contains empty string")
            break

    return errors
