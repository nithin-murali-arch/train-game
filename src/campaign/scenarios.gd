class_name Scenarios
extends RefCounted


static func create_bengal_charter_scenario() -> ScenarioData:
	var scenario := ScenarioData.new()
	scenario.scenario_id = "bengal_charter"
	scenario.display_name = "Bengal Charter"
	scenario.description = "A standalone tutorial covering the first three acts of the Bengal Railway Charter campaign."
	scenario.starting_money = 20000
	scenario.objectives = [
		_create_objective("obj_build_track", "build_track", 1, "Lay Your First Track", "Build track connecting two points (1 edge)."),
		_create_objective("obj_buy_train", "buy_train", 1, "Acquire an Engine", "Purchase your first train."),
		_create_objective("obj_create_route", "create_route", 1, "Open a Route", "Create a cargo route between two cities."),
		_create_objective("obj_complete_contract", "complete_contract", 1, "Fulfil a Contract", "Complete any delivery contract."),
		_create_objective("obj_reach_profit_5k", "reach_profit", 5000, "Show a Profit", "Reach a total profit of ₹5,000."),
		_create_objective("obj_upgrade_station", "upgrade_station", 1, "Improve a Station", "Upgrade any station facility by one level."),
		_create_objective("obj_reach_reputation_10", "reach_reputation", 10, "Gain Recognition", "Reach a reputation score of 10."),
	]
	scenario.win_condition = {"type": "all_objectives_complete"}
	scenario.loss_condition = {"type": "bankruptcy"}
	return scenario


static func create_port_monopoly_scenario() -> ScenarioData:
	var scenario := ScenarioData.new()
	scenario.scenario_id = "port_monopoly"
	scenario.display_name = "Port Monopoly"
	scenario.description = "Start with significant capital and pre-built track to both ports. Dominate the Bengal trade by securing 80% market share in Kolkata and Dacca."
	scenario.starting_money = 100000
	scenario.prebuilt_track = [
		{"from": "kolkata", "to": "patna"},
		{"from": "kolkata", "to": "murshidabad"},
		{"from": "dacca", "to": "murshidabad"},
		{"from": "dacca", "to": "patna"},
	]
	scenario.starting_trains = [
		{"train_id": "freight_engine", "city_id": "kolkata"},
		{"train_id": "mixed_engine", "city_id": "dacca"},
	]
	scenario.objectives = [
		_create_objective("obj_market_share_80", "reach_market_share", 80, "Dominate Port Trade", "Reach 80% market share across Kolkata and Dacca."),
	]
	scenario.win_condition = {"type": "all_objectives_complete"}
	scenario.loss_condition = {"type": "bankruptcy"}
	return scenario


static func create_monsoon_crisis_scenario() -> ScenarioData:
	var scenario := ScenarioData.new()
	scenario.scenario_id = "monsoon_crisis"
	scenario.display_name = "Monsoon Crisis"
	scenario.description = "The monsoons are coming. Start with limited funds, reduced track build costs, and survive three monsoon events while keeping your company profitable."
	scenario.starting_money = 30000
	scenario.modifiers = {"track_build_cost_multiplier": 0.5}
	scenario.objectives = [
		_create_objective("obj_survive_monsoon_3", "survive_event", 3, "Survive the Monsoons", "Survive 3 monsoon events while maintaining profitability."),
	]
	scenario.win_condition = {"type": "all_objectives_complete"}
	scenario.loss_condition = {"type": "bankruptcy"}
	return scenario


static func _create_objective(id: String, type: String, target: int, name: String, desc: String) -> CampaignObjective:
	var obj := CampaignObjective.new()
	obj.objective_id = id
	obj.type = type
	obj.target_value = target
	obj.display_name = name
	obj.description = desc
	return obj
