class_name ModifierValueData
extends Resource

@export var modifier_id: String = ""
@export var value: float = 0.0
@export var operation: String = "percent_add"
@export var target: String = ""
@export var description: String = ""

func validate() -> Array[String]:
    var errors: Array[String] = []

    if modifier_id.strip_edges().is_empty():
        errors.append("modifier_id is required")
    elif modifier_id != modifier_id.to_snake_case():
        errors.append("modifier_id must be lowercase snake_case: " + modifier_id)

    if target.strip_edges().is_empty():
        errors.append("target is required")

    var valid_operations := ["flat_add", "percent_add", "multiply", "override"]
    if not valid_operations.has(operation):
        errors.append("operation must be one of: flat_add, percent_add, multiply, override")

    match operation:
        "multiply":
            if value <= 0.0:
                errors.append("multiply operation requires value > 0")
        "override":
            if value < 0.0:
                errors.append("override operation requires value >= 0")

    return errors
