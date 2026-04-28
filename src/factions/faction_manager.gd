class_name FactionManager
extends RefCounted


const FACTION_PLAYER := "player_railway_company"
const FACTION_BRITISH := "british_east_india_rail"

var _player_treasury: TreasuryState
var _british_treasury: TreasuryState

var _selected_faction_id: String = FACTION_PLAYER
var _faction_bonuses: Array[FactionBonusData] = []


func setup(player_starting_capital: int = 50000, british_starting_capital: int = 50000, selected_bonuses: Array[FactionBonusData] = []) -> void:
	_player_treasury = TreasuryState.new(player_starting_capital)
	_british_treasury = TreasuryState.new(british_starting_capital)
	_faction_bonuses = selected_bonuses.duplicate()
	if not _faction_bonuses.is_empty():
		_selected_faction_id = _faction_bonuses[0].faction_id


func get_selected_faction_id() -> String:
	return _selected_faction_id


func get_faction_bonus() -> FactionBonusData:
	return _faction_bonuses[0] if not _faction_bonuses.is_empty() else null


func get_faction_bonuses() -> Array[FactionBonusData]:
	return _faction_bonuses.duplicate()


func apply_maintenance_discount(base_cost: int) -> int:
	for bonus in _faction_bonuses:
		if bonus.bonus_type == "maintenance_discount":
			return int(base_cost * (1.0 - bonus.bonus_value))
	return base_cost


func apply_track_cost_discount(base_cost: int) -> int:
	for bonus in _faction_bonuses:
		if bonus.bonus_type == "track_cost_discount":
			return int(base_cost * (1.0 - bonus.bonus_value))
	return base_cost


func apply_station_cost_discount(base_cost: int) -> int:
	for bonus in _faction_bonuses:
		if bonus.bonus_type == "station_cost_discount":
			return int(base_cost * (1.0 - bonus.bonus_value))
	return base_cost


func get_contract_reputation_bonus() -> int:
	for bonus in _faction_bonuses:
		if bonus.bonus_type == "contract_reputation_bonus":
			return int(bonus.bonus_value)
	return 0


func get_treasury_for_faction(faction_id: String) -> TreasuryState:
	match faction_id:
		FACTION_PLAYER:
			return _player_treasury
		FACTION_BRITISH:
			return _british_treasury
	return null


func add_money(faction_id: String, amount: int) -> bool:
	var treasury := get_treasury_for_faction(faction_id)
	if treasury == null:
		return false
	return treasury.add(amount)


func spend_money(faction_id: String, amount: int) -> bool:
	var treasury := get_treasury_for_faction(faction_id)
	if treasury == null:
		return false
	return treasury.spend(amount)


func can_afford(faction_id: String, amount: int) -> bool:
	var treasury := get_treasury_for_faction(faction_id)
	if treasury == null:
		return false
	return treasury.can_afford(amount)


func get_balance(faction_id: String) -> int:
	var treasury := get_treasury_for_faction(faction_id)
	if treasury == null:
		return 0
	return treasury.balance


func to_dict() -> Dictionary:
	return {
		"player_balance": _player_treasury.balance if _player_treasury != null else 0,
		"british_balance": _british_treasury.balance if _british_treasury != null else 0,
		"selected_faction_id": _selected_faction_id,
	}


func from_dict(dict: Dictionary) -> void:
	var player_balance := dict.get("player_balance", 0) as int
	var british_balance := dict.get("british_balance", 0) as int
	setup(player_balance, british_balance)
	_selected_faction_id = dict.get("selected_faction_id", FACTION_PLAYER) as String
