class_name ScenarioData
extends RefCounted


var scenario_id: String = ""
var display_name: String = ""
var description: String = ""
var starting_money: int = 0
var prebuilt_track: Array[Dictionary] = []  # {"from": city_id, "to": city_id}
var starting_trains: Array[Dictionary] = []  # {"train_id": train_id, "city_id": city_id}
var objectives: Array[CampaignObjective] = []
var win_condition: Dictionary = {}
var loss_condition: Dictionary = {}
var modifiers: Dictionary = {}  # scenario-specific modifiers, e.g. {"track_build_cost_multiplier": 0.5}


func to_dict() -> Dictionary:
	var objectives_dict: Array[Dictionary] = []
	for obj in objectives:
		if obj == null:
			continue
		objectives_dict.append(obj.to_dict())
	return {
		"scenario_id": scenario_id,
		"display_name": display_name,
		"description": description,
		"starting_money": starting_money,
		"prebuilt_track": prebuilt_track.duplicate(),
		"starting_trains": starting_trains.duplicate(),
		"objectives": objectives_dict,
		"win_condition": win_condition.duplicate(),
		"loss_condition": loss_condition.duplicate(),
		"modifiers": modifiers.duplicate(),
	}


static func from_dict(dict: Dictionary) -> ScenarioData:
	var scenario := ScenarioData.new()
	scenario.scenario_id = dict.get("scenario_id", "") as String
	scenario.display_name = dict.get("display_name", "") as String
	scenario.description = dict.get("description", "") as String
	scenario.starting_money = dict.get("starting_money", 0) as int

	var track_array: Array = dict.get("prebuilt_track", []) as Array
	for item in track_array:
		if typeof(item) == TYPE_DICTIONARY:
			scenario.prebuilt_track.append(item as Dictionary)

	var train_array: Array = dict.get("starting_trains", []) as Array
	for item in train_array:
		if typeof(item) == TYPE_DICTIONARY:
			scenario.starting_trains.append(item as Dictionary)

	var obj_array: Array = dict.get("objectives", []) as Array
	for item in obj_array:
		if typeof(item) == TYPE_DICTIONARY:
			scenario.objectives.append(CampaignObjective.from_dict(item as Dictionary))

	scenario.win_condition = dict.get("win_condition", {}) as Dictionary
	scenario.loss_condition = dict.get("loss_condition", {}) as Dictionary
	scenario.modifiers = dict.get("modifiers", {}) as Dictionary
	return scenario
