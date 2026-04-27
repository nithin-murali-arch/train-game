class_name ContractsPanel
extends PanelContainer


signal contract_accepted(contract_id: String)
signal cancelled

@onready var _title_label: Label = %TitleLabel
@onready var _available_list: VBoxContainer = %AvailableList
@onready var _accepted_list: VBoxContainer = %AcceptedList
@onready var _close_btn: Button = %CloseButton

var _route_toy: Node


func _ready() -> void:
	_close_btn.pressed.connect(_on_close)
	visible = false


func open(route_toy_ref: Node) -> void:
	_route_toy = route_toy_ref
	_refresh()
	visible = true


func close() -> void:
	visible = false


func _refresh() -> void:
	_clear_list(_available_list)
	_clear_list(_accepted_list)

	if _route_toy == null or _route_toy.contract_manager == null:
		return

	var cm: ContractManager = _route_toy.contract_manager
	var city_names: Dictionary = _route_toy.get_city_display_names() if _route_toy.has_method("get_city_display_names") else {}

	# Available contracts
	for contract in cm.get_available_contracts():
		var row := _create_contract_row(contract, city_names, true)
		_available_list.add_child(row)

	if _available_list.get_child_count() == 0:
		var empty := Label.new()
		empty.text = "No available contracts"
		_available_list.add_child(empty)

	# Accepted contracts
	for contract in cm.get_accepted_contracts():
		var row := _create_contract_row(contract, city_names, false)
		_accepted_list.add_child(row)

	if _accepted_list.get_child_count() == 0:
		var empty := Label.new()
		empty.text = "No active contracts"
		_accepted_list.add_child(empty)


func _clear_list(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()


func _create_contract_row(contract: ContractRuntimeState, city_names: Dictionary, is_available: bool) -> Control:
	var panel := PanelContainer.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	margin.add_child(vbox)

	# Title row
	var title := Label.new()
	title.text = contract.display_name
	title.add_theme_font_size_override("font_size", 14)
	vbox.add_child(title)

	# Details
	var origin_name: String = city_names.get(contract.origin_city_id, contract.origin_city_id) as String
	var dest_name: String = city_names.get(contract.destination_city_id, contract.destination_city_id) as String

	var details := Label.new()
	details.text = "%s → %s | %s" % [origin_name, dest_name, contract.cargo_id.capitalize()]
	vbox.add_child(details)

	var qty := Label.new()
	qty.text = "Progress: %d / %d" % [contract.delivered_quantity, contract.required_quantity]
	vbox.add_child(qty)

	var reward := Label.new()
	reward.text = "Reward: ₹%s | Penalty: ₹%s" % [_comma_sep(contract.reward_money), _comma_sep(contract.penalty_money)]
	vbox.add_child(reward)

	var rep := Label.new()
	rep.text = "Rep: +%d / -%d" % [contract.reputation_reward, contract.reputation_penalty]
	vbox.add_child(rep)

	if is_available:
		var accept_btn := Button.new()
		accept_btn.text = "Accept"
		accept_btn.pressed.connect(func(): _on_accept(contract.contract_id))
		vbox.add_child(accept_btn)
	else:
		var status := Label.new()
		status.text = "Status: %s" % contract.get_status_name()
		vbox.add_child(status)

	return panel


func _on_accept(contract_id: String) -> void:
	if _route_toy == null or _route_toy.contract_manager == null or _route_toy.clock == null:
		return
	var cm: ContractManager = _route_toy.contract_manager
	var ok := cm.accept_contract(contract_id, _route_toy.clock.current_day, _route_toy.clock.current_month, _route_toy.clock.current_year)
	if ok:
		contract_accepted.emit(contract_id)
	_refresh()


func _on_close() -> void:
	cancelled.emit()
	close()


static func _comma_sep(n: int) -> String:
	var s := str(n)
	var result := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result
