class_name ContractData
extends RefCounted


var contract_id: String = ""
var display_name: String = ""
var origin_city_id: String = ""
var destination_city_id: String = ""
var cargo_id: String = ""
var required_quantity: int = 0
var deadline_days: int = 0
var reward_money: int = 0
var penalty_money: int = 0
var reputation_reward: int = 0
var reputation_penalty: int = 0


func validate() -> Array[String]:
	var errors: Array[String] = []
	if contract_id.strip_edges().is_empty():
		errors.append("contract_id is required")
	if display_name.strip_edges().is_empty():
		errors.append("display_name is required")
	if origin_city_id.strip_edges().is_empty():
		errors.append("origin_city_id is required")
	if destination_city_id.strip_edges().is_empty():
		errors.append("destination_city_id is required")
	if cargo_id.strip_edges().is_empty():
		errors.append("cargo_id is required")
	if required_quantity <= 0:
		errors.append("required_quantity must be > 0")
	if deadline_days <= 0:
		errors.append("deadline_days must be > 0")
	if reward_money < 0:
		errors.append("reward_money must be >= 0")
	if penalty_money < 0:
		errors.append("penalty_money must be >= 0")
	return errors
