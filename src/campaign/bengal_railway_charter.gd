class_name BengalRailwayCharter
extends RefCounted


static func create_campaign() -> CampaignData:
	var campaign := CampaignData.new()
	campaign.campaign_id = "bengal_railway_charter"
	campaign.display_name = "Bengal Railway Charter"
	campaign.description = "Build a railway empire across Colonial Bengal, from your first line to the Royal Charter."
	campaign.starting_money = 20000
	campaign.starting_cities = ["kolkata"]
	campaign.acts = [
		_create_act_1(),
		_create_act_2(),
		_create_act_3(),
		_create_act_4(),
		_create_act_5(),
	]
	return campaign


static func _create_act_1() -> CampaignData.CampaignActData:
	var act := CampaignData.CampaignActData.new()
	act.act_id = "first_line"
	act.display_name = "First Line"
	act.description = "Learn the basics of track building, train purchase, and route creation."
	act.objectives = [
		_create_objective("obj_build_track", "build_track", 1, "Lay Your First Track", "Build track connecting two points (1 edge)."),
		_create_objective("obj_buy_train", "buy_train", 1, "Acquire an Engine", "Purchase your first train."),
		_create_objective("obj_create_route", "create_route", 1, "Open a Route", "Create a cargo route between two cities."),
	]
	act.next_act_hint = "commercial_mandate"
	return act


static func _create_act_2() -> CampaignData.CampaignActData:
	var act := CampaignData.CampaignActData.new()
	act.act_id = "commercial_mandate"
	act.display_name = "Commercial Mandate"
	act.description = "Prove the railway can turn a profit by fulfilling contracts and earning revenue."
	act.objectives = [
		_create_objective("obj_complete_contract", "complete_contract", 1, "Fulfil a Contract", "Complete any delivery contract."),
		_create_objective("obj_reach_profit_5k", "reach_profit", 5000, "Show a Profit", "Reach a total profit of ₹5,000."),
	]
	act.next_act_hint = "station_investment"
	return act


static func _create_act_3() -> CampaignData.CampaignActData:
	var act := CampaignData.CampaignActData.new()
	act.act_id = "station_investment"
	act.display_name = "Station Investment"
	act.description = "Expand infrastructure and build your reputation with the colonial administration."
	act.objectives = [
		_create_objective("obj_upgrade_station", "upgrade_station", 1, "Improve a Station", "Upgrade any station facility by one level."),
		_create_objective("obj_reach_reputation_10", "reach_reputation", 10, "Gain Recognition", "Reach a reputation score of 10."),
	]
	act.next_act_hint = "rival_pressure"
	return act


static func _create_act_4() -> CampaignData.CampaignActData:
	var act := CampaignData.CampaignActData.new()
	act.act_id = "rival_pressure"
	act.display_name = "Rival Pressure"
	act.description = "A competitor has entered Bengal. Outperform them in market share and profit."
	act.objectives = [
		_create_objective("obj_reach_market_share_50", "reach_market_share", 50, "Dominate the Market", "Reach 50% market share across Bengal."),
		_create_objective("obj_reach_profit_20k", "reach_profit", 20000, "Expand Profits", "Reach a total profit of ₹20,000."),
	]
	act.next_act_hint = "crisis_and_charter"
	return act


static func _create_act_5() -> CampaignData.CampaignActData:
	var act := CampaignData.CampaignActData.new()
	act.act_id = "crisis_and_charter"
	act.display_name = "Crisis and Charter"
	act.description = "Survive a colonial crisis and prove your railway deserves the Royal Charter."
	act.objectives = [
		_create_objective("obj_survive_event", "survive_event", 1, "Weather the Storm", "Survive one major event without bankruptcy."),
		_create_objective("obj_reach_reputation_30", "reach_reputation", 30, "Earn the Charter", "Reach a reputation score of 30."),
		_create_objective("obj_reach_profit_50k", "reach_profit", 50000, "Imperial Profits", "Reach a total profit of ₹50,000."),
	]
	act.next_act_hint = ""
	return act


static func _create_objective(id: String, type: String, target: int, name: String, desc: String) -> CampaignObjective:
	var obj := CampaignObjective.new()
	obj.objective_id = id
	obj.type = type
	obj.target_value = target
	obj.display_name = name
	obj.description = desc
	return obj
