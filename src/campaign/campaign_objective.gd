class_name CampaignObjective
extends RefCounted


var objective_id: String = ""
var type: String = ""
var target_value: int = 0
var current_value: int = 0
var display_name: String = ""
var description: String = ""
var is_complete: bool = false
var reward_text: String = ""


func update_progress(delta: int = 1) -> void:
	current_value += delta
	_check_completion()


func set_progress(value: int) -> void:
	current_value = value
	_check_completion()


func check_completion() -> bool:
	return current_value >= target_value


func get_progress_text() -> String:
	if type == "reach_market_share":
		return "%d%%" % current_value
	return "%d / %d" % [current_value, target_value]


func to_dict() -> Dictionary:
	return {
		"objective_id": objective_id,
		"type": type,
		"target_value": target_value,
		"current_value": current_value,
		"display_name": display_name,
		"description": description,
		"is_complete": is_complete,
		"reward_text": reward_text,
	}


static func from_dict(dict: Dictionary) -> CampaignObjective:
	var obj := CampaignObjective.new()
	obj.objective_id = dict.get("objective_id", "") as String
	obj.type = dict.get("type", "") as String
	obj.target_value = dict.get("target_value", 0) as int
	obj.current_value = dict.get("current_value", 0) as int
	obj.display_name = dict.get("display_name", "") as String
	obj.description = dict.get("description", "") as String
	obj.is_complete = dict.get("is_complete", false) as bool
	obj.reward_text = dict.get("reward_text", "") as String
	return obj


func _check_completion() -> void:
	is_complete = current_value >= target_value
