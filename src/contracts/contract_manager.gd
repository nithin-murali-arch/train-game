class_name ContractManager
extends RefCounted


signal contract_available_added(contract_state: ContractRuntimeState)
signal contract_accepted(contract_state: ContractRuntimeState)
signal contract_completed(contract_state: ContractRuntimeState)
signal contract_failed(contract_state: ContractRuntimeState)
signal contract_expired(contract_state: ContractRuntimeState)
signal reputation_changed(new_reputation: int)

var _available: Array[ContractRuntimeState] = []
var _accepted: Array[ContractRuntimeState] = []
var _completed: Array[ContractRuntimeState] = []
var _failed: Array[ContractRuntimeState] = []

var _city_data_by_id: Dictionary = {}
var _cargo_catalog: Dictionary = {}
var _treasury: TreasuryState = null
var _reputation: int = 0
var _reputation_callback: Callable = Callable()

var _contract_counter: int = 1
var _last_refresh_day: int = 0
var _refresh_interval_days: int = 7
var _target_available_count: int = 4


func setup(
	city_data_by_id: Dictionary,
	cargo_catalog: Dictionary,
	treasury: TreasuryState,
	reputation_callback: Callable = Callable()
) -> void:
	_city_data_by_id = city_data_by_id
	_cargo_catalog = cargo_catalog
	_treasury = treasury
	_reputation_callback = reputation_callback


func get_reputation() -> int:
	return _reputation


func set_reputation(value: int) -> void:
	_reputation = value
	reputation_changed.emit(_reputation)
	if _reputation_callback.is_valid():
		_reputation_callback.call(_reputation)


func get_available_contracts() -> Array[ContractRuntimeState]:
	return _available.duplicate()


func get_accepted_contracts() -> Array[ContractRuntimeState]:
	return _accepted.duplicate()


func get_completed_contracts() -> Array[ContractRuntimeState]:
	return _completed.duplicate()


func get_failed_contracts() -> Array[ContractRuntimeState]:
	return _failed.duplicate()


func generate_contracts_if_needed(current_day: int, _month: int, _year: int) -> void:
	if _available.is_empty() or (current_day - _last_refresh_day) >= _refresh_interval_days:
		_generate_contracts(current_day)
		_last_refresh_day = current_day


func _generate_contracts(current_day: int) -> void:
	var city_ids: Array[String] = []
	for city_id in _city_data_by_id.keys():
		city_ids.append(city_id)

	var cargo_ids: Array[String] = []
	for cargo_id in _cargo_catalog.keys():
		cargo_ids.append(cargo_id)

	if city_ids.size() < 2 or cargo_ids.is_empty():
		return

	# Fill up to target count
	while _available.size() < _target_available_count:
		var origin_id: String = city_ids[randi() % city_ids.size()]
		var dest_id: String = city_ids[randi() % city_ids.size()]
		while dest_id == origin_id:
			dest_id = city_ids[randi() % city_ids.size()]

		var cargo_id: String = cargo_ids[randi() % cargo_ids.size()]
		var cargo: CargoData = _cargo_catalog.get(cargo_id, null) as CargoData
		if cargo == null:
			continue

		var origin_data: CityData = _city_data_by_id.get(origin_id, null) as CityData
		var dest_data: CityData = _city_data_by_id.get(dest_id, null) as CityData
		if origin_data == null or dest_data == null:
			continue

		var required_qty: int = 20 + (randi() % 81)  # 20–100
		var deadline_days: int = 14 + (randi() % 29)  # 14–42 days
		var base_reward: int = int(roundf(required_qty * cargo.base_price * 1.5))
		var penalty: int = base_reward / 4

		var contract := ContractRuntimeState.new()
		contract.contract_id = "contract_%03d" % _contract_counter
		_contract_counter += 1
		contract.display_name = "%s Delivery to %s" % [cargo_id.capitalize(), dest_data.display_name]
		contract.origin_city_id = origin_id
		contract.destination_city_id = dest_id
		contract.cargo_id = cargo_id
		contract.required_quantity = required_qty
		contract.deadline_day = current_day + deadline_days
		contract.deadline_month = 0  # simplified: use absolute day counting
		contract.deadline_year = 0
		contract.reward_money = base_reward
		contract.penalty_money = penalty
		contract.reputation_reward = 5
		contract.reputation_penalty = 3
		contract.status = ContractRuntimeState.Status.AVAILABLE

		_available.append(contract)
		contract_available_added.emit(contract)


func accept_contract(contract_id: String, current_day: int, current_month: int, current_year: int) -> bool:
	var contract: ContractRuntimeState = _find_in_available(contract_id)
	if contract == null:
		return false

	_available.erase(contract)
	contract.status = ContractRuntimeState.Status.ACCEPTED
	contract.accepted_day = current_day
	contract.accepted_month = current_month
	contract.accepted_year = current_year
	_accepted.append(contract)
	contract_accepted.emit(contract)
	return true


func record_delivery(cargo_id: String, destination_city_id: String, quantity: int) -> void:
	for contract in _accepted:
		if contract.cargo_id == cargo_id and contract.destination_city_id == destination_city_id:
			contract.delivered_quantity += quantity
			if contract.delivered_quantity >= contract.required_quantity:
				_complete_contract(contract)


func check_deadlines(current_day: int, _month: int, _year: int) -> void:
	var to_remove: Array[ContractRuntimeState] = []
	for contract in _accepted:
		if contract.deadline_day > 0 and current_day > contract.deadline_day:
			to_remove.append(contract)

	for contract in to_remove:
		_accepted.erase(contract)
		contract.status = ContractRuntimeState.Status.EXPIRED
		_failed.append(contract)
		_apply_penalty(contract)
		contract_expired.emit(contract)


func _complete_contract(contract: ContractRuntimeState) -> void:
	_accepted.erase(contract)
	contract.status = ContractRuntimeState.Status.COMPLETED
	_completed.append(contract)

	if _treasury != null:
		_treasury.add(contract.reward_money)

	set_reputation(_reputation + contract.reputation_reward)
	contract_completed.emit(contract)


func _apply_penalty(contract: ContractRuntimeState) -> void:
	if _treasury != null and contract.penalty_money > 0:
		if _treasury.can_afford(contract.penalty_money):
			_treasury.spend(contract.penalty_money)
		else:
			_treasury.spend(_treasury.balance)  # drain what we can

	set_reputation(_reputation - contract.reputation_penalty)
	contract_failed.emit(contract)


func _find_in_available(contract_id: String) -> ContractRuntimeState:
	for contract in _available:
		if contract.contract_id == contract_id:
			return contract
	return null


func to_dict() -> Dictionary:
	return {
		"reputation": _reputation,
		"contract_counter": _contract_counter,
		"last_refresh_day": _last_refresh_day,
		"available": _contracts_to_dict_array(_available),
		"accepted": _contracts_to_dict_array(_accepted),
		"completed": _contracts_to_dict_array(_completed),
		"failed": _contracts_to_dict_array(_failed),
	}


static func from_dict(dict: Dictionary) -> ContractManager:
	var cm := ContractManager.new()
	cm._reputation = dict.get("reputation", 0) as int
	cm._contract_counter = dict.get("contract_counter", 1) as int
	cm._last_refresh_day = dict.get("last_refresh_day", 0) as int
	cm._available = _dict_array_to_contracts(dict.get("available", []))
	cm._accepted = _dict_array_to_contracts(dict.get("accepted", []))
	cm._completed = _dict_array_to_contracts(dict.get("completed", []))
	cm._failed = _dict_array_to_contracts(dict.get("failed", []))
	return cm


static func _contracts_to_dict_array(contracts: Array[ContractRuntimeState]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for contract in contracts:
		result.append(contract.to_dict())
	return result


static func _dict_array_to_contracts(arr: Variant) -> Array[ContractRuntimeState]:
	var result: Array[ContractRuntimeState] = []
	if typeof(arr) != TYPE_ARRAY:
		return result
	for item in arr as Array:
		if typeof(item) == TYPE_DICTIONARY:
			result.append(ContractRuntimeState.from_dict(item as Dictionary))
	return result
