class_name CampaignData
extends RefCounted


var campaign_id: String = ""
var display_name: String = ""
var description: String = ""
var starting_money: int = 0
var starting_cities: Array[String] = []
var acts: Array[CampaignActData] = []


class CampaignActData:
	extends RefCounted

	var act_id: String = ""
	var display_name: String = ""
	var description: String = ""
	var objectives: Array[CampaignObjective] = []
	var next_act_hint: String = ""


	func to_dict() -> Dictionary:
		var objectives_dict: Array[Dictionary] = []
		for obj in objectives:
			objectives_dict.append(obj.to_dict())
		return {
			"act_id": act_id,
			"display_name": display_name,
			"description": description,
			"objectives": objectives_dict,
			"next_act_hint": next_act_hint,
		}


	static func from_dict(dict: Dictionary) -> CampaignActData:
		var act := CampaignActData.new()
		act.act_id = dict.get("act_id", "") as String
		act.display_name = dict.get("display_name", "") as String
		act.description = dict.get("description", "") as String
		act.next_act_hint = dict.get("next_act_hint", "") as String

		var obj_array: Array = dict.get("objectives", []) as Array
		for item in obj_array:
			if typeof(item) == TYPE_DICTIONARY:
				act.objectives.append(CampaignObjective.from_dict(item as Dictionary))
		return act


func to_dict() -> Dictionary:
	var acts_dict: Array[Dictionary] = []
	for act in acts:
		acts_dict.append(act.to_dict())
	return {
		"campaign_id": campaign_id,
		"display_name": display_name,
		"description": description,
		"starting_money": starting_money,
		"starting_cities": starting_cities.duplicate(),
		"acts": acts_dict,
	}


static func from_dict(dict: Dictionary) -> CampaignData:
	var campaign := CampaignData.new()
	campaign.campaign_id = dict.get("campaign_id", "") as String
	campaign.display_name = dict.get("display_name", "") as String
	campaign.description = dict.get("description", "") as String
	campaign.starting_money = dict.get("starting_money", 0) as int

	var cities: Array = dict.get("starting_cities", []) as Array
	for city in cities:
		if typeof(city) == TYPE_STRING:
			campaign.starting_cities.append(city as String)

	var acts_array: Array = dict.get("acts", []) as Array
	for item in acts_array:
		if typeof(item) == TYPE_DICTIONARY:
			campaign.acts.append(CampaignActData.from_dict(item as Dictionary))
	return campaign
