class_name CampaignManager
extends Node


signal act_advanced(new_act_index: int)
signal victory
signal loss
signal objective_updated(objective: CampaignObjective)


enum CampaignState {
	IN_PROGRESS,
	VICTORY,
	LOSS,
}


var current_campaign: CampaignData = null
var current_act_index: int = 0
var objective_states: Array[CampaignObjective] = []
var campaign_state: CampaignState = CampaignState.IN_PROGRESS


func start_campaign(campaign_id: String) -> bool:
	if current_campaign == null or current_campaign.campaign_id != campaign_id:
		push_error("Campaign not loaded: " + campaign_id)
		return false

	current_act_index = 0
	_flatten_objectives()
	campaign_state = CampaignState.IN_PROGRESS
	return true


func tick_objectives(route_toy: RouteToyPlayable) -> void:
	if campaign_state != CampaignState.IN_PROGRESS:
		return

	var changed := false
	for objective in objective_states:
		if objective.is_complete:
			continue
		var new_value := check_objective_type(objective.type, route_toy)
		objective.set_progress(new_value)
		if objective.is_complete:
			changed = true
			objective_updated.emit(objective)

	if changed:
		_check_act_completion()


func check_objective_type(type: String, route_toy: RouteToyPlayable) -> int:
	match type:
		"build_track":
			if route_toy.graph != null:
				return route_toy.graph.get_edge_count()
			return 0
		"buy_train":
			return route_toy.owned_trains.size()
		"create_route":
			return route_toy.active_runners.size()
		"complete_contract":
			if route_toy.contract_manager != null:
				return route_toy.contract_manager.get_completed_contracts().size()
			return 0
		"upgrade_station":
			return _count_upgraded_stations(route_toy)
		"reach_profit":
			return _sum_route_profits(route_toy)
		"reach_reputation":
			return route_toy.reputation
		"reach_market_share":
			return int(route_toy.get_player_market_share() * 100.0)
		"survive_event":
			return 1 if _has_no_active_negative_events(route_toy) else 0
		_:
			push_warning("Unknown objective type: " + type)
			return 0


func advance_act() -> void:
	if current_campaign == null:
		return
	if current_act_index >= current_campaign.acts.size() - 1:
		trigger_victory()
		return

	current_act_index += 1
	_flatten_objectives()
	act_advanced.emit(current_act_index)


func trigger_victory() -> void:
	campaign_state = CampaignState.VICTORY
	victory.emit()


func trigger_loss() -> void:
	campaign_state = CampaignState.LOSS
	loss.emit()


func get_current_act() -> CampaignData.CampaignActData:
	if current_campaign == null:
		return null
	if current_act_index < 0 or current_act_index >= current_campaign.acts.size():
		return null
	return current_campaign.acts[current_act_index]


func get_current_objectives() -> Array[CampaignObjective]:
	return objective_states.duplicate()


func to_dict() -> Dictionary:
	var objectives_dict: Array[Dictionary] = []
	for obj in objective_states:
		objectives_dict.append(obj.to_dict())
	return {
		"campaign_id": current_campaign.campaign_id if current_campaign != null else "",
		"current_act_index": current_act_index,
		"campaign_state": campaign_state,
		"objective_states": objectives_dict,
	}


func from_dict(dict: Dictionary) -> void:
	current_act_index = dict.get("current_act_index", 0) as int
	campaign_state = dict.get("campaign_state", CampaignState.IN_PROGRESS) as int

	objective_states.clear()
	var obj_array: Array = dict.get("objective_states", []) as Array
	for item in obj_array:
		if typeof(item) == TYPE_DICTIONARY:
			objective_states.append(CampaignObjective.from_dict(item as Dictionary))


# ------------------------------------------------------------------------------
# Private helpers
# ------------------------------------------------------------------------------

func _flatten_objectives() -> void:
	objective_states.clear()
	var act := get_current_act()
	if act == null:
		return
	for obj in act.objectives:
		objective_states.append(obj)


func _check_act_completion() -> void:
	if campaign_state != CampaignState.IN_PROGRESS:
		return
	for objective in objective_states:
		if not objective.is_complete:
			return
	advance_act()


func _count_upgraded_stations(route_toy: RouteToyPlayable) -> int:
	var count := 0
	for city_id in route_toy.station_upgrades.keys():
		var upgrades: StationUpgradeState = route_toy.station_upgrades[city_id] as StationUpgradeState
		if upgrades != null and (
			upgrades.warehouse_level > 0
			or upgrades.loading_bay_level > 0
			or upgrades.maintenance_shed_level > 0
		):
			count += 1
	return count


func _sum_route_profits(route_toy: RouteToyPlayable) -> int:
	var total := 0
	for runner in route_toy.active_runners:
		if runner == null:
			continue
		var stats: RouteProfitStats = runner.get_stats()
		if stats != null:
			total += stats.total_profit
	return total


func _has_no_active_negative_events(route_toy: RouteToyPlayable) -> bool:
	var active_events: Array[EventRuntimeState] = route_toy.get_active_events()
	for event in active_events:
		if event.event_type != "port_boom":
			return false
	return true
