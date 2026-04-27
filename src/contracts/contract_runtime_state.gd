class_name ContractRuntimeState
extends RefCounted


enum Status {
	AVAILABLE,
	ACCEPTED,
	COMPLETED,
	FAILED,
	EXPIRED,
}

var contract_id: String = ""
var display_name: String = ""
var origin_city_id: String = ""
var destination_city_id: String = ""
var cargo_id: String = ""
var required_quantity: int = 0
var delivered_quantity: int = 0

var accepted_day: int = 0
var accepted_month: int = 0
var accepted_year: int = 0

var deadline_day: int = 0
var deadline_month: int = 0
var deadline_year: int = 0

var reward_money: int = 0
var penalty_money: int = 0
var reputation_reward: int = 0
var reputation_penalty: int = 0

var status: int = Status.AVAILABLE
var assigned_route_instance_id: String = ""


func get_status_name() -> String:
	match status:
		Status.AVAILABLE: return "Available"
		Status.ACCEPTED: return "Accepted"
		Status.COMPLETED: return "Completed"
		Status.FAILED: return "Failed"
		Status.EXPIRED: return "Expired"
		_: return "Unknown"


func to_dict() -> Dictionary:
	return {
		"contract_id": contract_id,
		"display_name": display_name,
		"origin_city_id": origin_city_id,
		"destination_city_id": destination_city_id,
		"cargo_id": cargo_id,
		"required_quantity": required_quantity,
		"delivered_quantity": delivered_quantity,
		"accepted_day": accepted_day,
		"accepted_month": accepted_month,
		"accepted_year": accepted_year,
		"deadline_day": deadline_day,
		"deadline_month": deadline_month,
		"deadline_year": deadline_year,
		"reward_money": reward_money,
		"penalty_money": penalty_money,
		"reputation_reward": reputation_reward,
		"reputation_penalty": reputation_penalty,
		"status": get_status_name(),
		"assigned_route_instance_id": assigned_route_instance_id,
	}


static func from_dict(dict: Dictionary) -> ContractRuntimeState:
	var s := ContractRuntimeState.new()
	s.contract_id = dict.get("contract_id", "") as String
	s.display_name = dict.get("display_name", "") as String
	s.origin_city_id = dict.get("origin_city_id", "") as String
	s.destination_city_id = dict.get("destination_city_id", "") as String
	s.cargo_id = dict.get("cargo_id", "") as String
	s.required_quantity = dict.get("required_quantity", 0) as int
	s.delivered_quantity = dict.get("delivered_quantity", 0) as int
	s.accepted_day = dict.get("accepted_day", 0) as int
	s.accepted_month = dict.get("accepted_month", 0) as int
	s.accepted_year = dict.get("accepted_year", 0) as int
	s.deadline_day = dict.get("deadline_day", 0) as int
	s.deadline_month = dict.get("deadline_month", 0) as int
	s.deadline_year = dict.get("deadline_year", 0) as int
	s.reward_money = dict.get("reward_money", 0) as int
	s.penalty_money = dict.get("penalty_money", 0) as int
	s.reputation_reward = dict.get("reputation_reward", 0) as int
	s.reputation_penalty = dict.get("reputation_penalty", 0) as int
	s.assigned_route_instance_id = dict.get("assigned_route_instance_id", "") as String
	var status_str: String = dict.get("status", "Available") as String
	s.status = _status_from_name(status_str)
	return s


static func _status_from_name(name: String) -> int:
	match name:
		"Available": return Status.AVAILABLE
		"Accepted": return Status.ACCEPTED
		"Completed": return Status.COMPLETED
		"Failed": return Status.FAILED
		"Expired": return Status.EXPIRED
		_: return Status.AVAILABLE
