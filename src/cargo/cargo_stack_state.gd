class_name CargoStackState
extends RefCounted


var cargo_id: String
var quantity: int


func _init(p_cargo_id: String = "", p_quantity: int = 0) -> void:
	cargo_id = p_cargo_id
	quantity = p_quantity


func is_empty() -> bool:
	return quantity <= 0


func validate() -> Array[String]:
	var errors: Array[String] = []

	if cargo_id.strip_edges().is_empty():
		errors.append("cargo_id is required")
	elif cargo_id != cargo_id.to_snake_case():
		errors.append("cargo_id must be lowercase snake_case: " + cargo_id)

	if quantity < 0:
		errors.append("quantity must be non-negative")

	return errors
