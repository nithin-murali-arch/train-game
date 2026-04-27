class_name StationUpgradeState
extends RefCounted


var warehouse_level: int = 0
var loading_bay_level: int = 0
var maintenance_shed_level: int = 0

const WAREHOUSE_COSTS: Array[int] = [2000, 5000, 10000]
const LOADING_BAY_COSTS: Array[int] = [3000, 6000, 12000]
const MAINTENANCE_SHED_COSTS: Array[int] = [2500, 5500, 9000]

const MAINTENANCE_DISCOUNTS: Array[float] = [0.0, 0.1, 0.2, 0.3]


func get_warehouse_cost() -> int:
	if warehouse_level >= WAREHOUSE_COSTS.size():
		return 0
	return WAREHOUSE_COSTS[warehouse_level]


func get_loading_bay_cost() -> int:
	if loading_bay_level >= LOADING_BAY_COSTS.size():
		return 0
	return LOADING_BAY_COSTS[loading_bay_level]


func get_maintenance_shed_cost() -> int:
	if maintenance_shed_level >= MAINTENANCE_SHED_COSTS.size():
		return 0
	return MAINTENANCE_SHED_COSTS[maintenance_shed_level]


func get_maintenance_discount() -> float:
	return MAINTENANCE_DISCOUNTS[mini(maintenance_shed_level, MAINTENANCE_DISCOUNTS.size() - 1)]


func can_upgrade_warehouse() -> bool:
	return warehouse_level < WAREHOUSE_COSTS.size()


func can_upgrade_loading_bay() -> bool:
	return loading_bay_level < LOADING_BAY_COSTS.size()


func can_upgrade_maintenance_shed() -> bool:
	return maintenance_shed_level < MAINTENANCE_SHED_COSTS.size()


func upgrade_warehouse() -> bool:
	if not can_upgrade_warehouse():
		return false
	warehouse_level += 1
	return true


func upgrade_loading_bay() -> bool:
	if not can_upgrade_loading_bay():
		return false
	loading_bay_level += 1
	return true


func upgrade_maintenance_shed() -> bool:
	if not can_upgrade_maintenance_shed():
		return false
	maintenance_shed_level += 1
	return true


func to_dict() -> Dictionary:
	return {
		"warehouse_level": warehouse_level,
		"loading_bay_level": loading_bay_level,
		"maintenance_shed_level": maintenance_shed_level,
	}


static func from_dict(dict: Dictionary) -> StationUpgradeState:
	var s := StationUpgradeState.new()
	s.warehouse_level = dict.get("warehouse_level", 0) as int
	s.loading_bay_level = dict.get("loading_bay_level", 0) as int
	s.maintenance_shed_level = dict.get("maintenance_shed_level", 0) as int
	return s
