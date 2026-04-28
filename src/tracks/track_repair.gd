class_name TrackRepair
extends RefCounted


const COST_PER_KM := 200


func calculate_repair_cost(edge: TrackEdgeData) -> int:
	if edge == null:
		return 0
	var damage := 1.0 - edge.condition
	var raw_cost := damage * edge.length_km * COST_PER_KM
	return int(ceilf(raw_cost))


func can_repair(edge: TrackEdgeData, treasury: TreasuryState) -> bool:
	if edge == null or treasury == null:
		return false
	var cost := calculate_repair_cost(edge)
	return cost > 0 and treasury.can_afford(cost)


func repair_edge(edge: TrackEdgeData, treasury: TreasuryState) -> bool:
	if edge == null or treasury == null:
		return false
	var cost := calculate_repair_cost(edge)
	if cost <= 0:
		return false
	if not treasury.spend(cost):
		return false
	edge.condition = 1.0
	return true
