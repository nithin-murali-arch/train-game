class_name FactionManager
extends RefCounted


const FACTION_PLAYER := "player_railway_company"
const FACTION_BRITISH := "british_east_india_rail"

var _player_treasury: TreasuryState
var _british_treasury: TreasuryState


func setup(player_starting_capital: int = 50000, british_starting_capital: int = 50000) -> void:
	_player_treasury = TreasuryState.new(player_starting_capital)
	_british_treasury = TreasuryState.new(british_starting_capital)


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
	}


func from_dict(dict: Dictionary) -> void:
	var player_balance := dict.get("player_balance", 0) as int
	var british_balance := dict.get("british_balance", 0) as int
	setup(player_balance, british_balance)
