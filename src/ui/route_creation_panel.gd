class_name RouteCreationPanel
extends PanelContainer


signal route_created(params: Dictionary)
signal cancelled

@onready var _title_label: Label = %TitleLabel
@onready var _train_option: OptionButton = %TrainOption
@onready var _origin_option: OptionButton = %OriginOption
@onready var _destination_option: OptionButton = %DestinationOption
@onready var _cargo_option: OptionButton = %CargoOption
@onready var _loop_check: CheckBox = %LoopCheck
@onready var _return_empty_check: CheckBox = %ReturnEmptyCheck
@onready var _estimate_label: Label = %EstimateLabel
@onready var _warnings_label: Label = %WarningsLabel
@onready var _create_btn: Button = %CreateButton
@onready var _cancel_btn: Button = %CancelButton

var _train_names: Array[String] = []
var _city_names: Dictionary = {}
var _cargo_ids: Array[String] = []
var _route_toy: Node


func _ready() -> void:
	_create_btn.pressed.connect(_on_create)
	_cancel_btn.pressed.connect(_on_cancel)
	_train_option.item_selected.connect(_on_selection_changed)
	_origin_option.item_selected.connect(_on_selection_changed)
	_destination_option.item_selected.connect(_on_selection_changed)
	_cargo_option.item_selected.connect(_on_selection_changed)
	_loop_check.toggled.connect(_on_selection_changed.bind(0))
	_return_empty_check.toggled.connect(_on_selection_changed.bind(0))
	visible = false


func open(train_names: Array[String], city_names: Dictionary, cargo_ids: Array[String], route_toy_ref: Node) -> void:
	_train_names = train_names
	_city_names = city_names
	_cargo_ids = cargo_ids
	_route_toy = route_toy_ref

	_train_option.clear()
	for i in range(train_names.size()):
		_train_option.add_item(train_names[i])
		_train_option.set_item_metadata(i, i)

	_origin_option.clear()
	_destination_option.clear()
	var idx := 0
	for city_id in city_names.keys():
		_origin_option.add_item(city_names[city_id])
		_origin_option.set_item_metadata(idx, city_id)
		_destination_option.add_item(city_names[city_id])
		_destination_option.set_item_metadata(idx, city_id)
		idx += 1

	_cargo_option.clear()
	for cargo_id in cargo_ids:
		_cargo_option.add_item(cargo_id.capitalize())
		_cargo_option.set_item_metadata(_cargo_option.item_count - 1, cargo_id)

	_loop_check.button_pressed = true
	_return_empty_check.button_pressed = true

	_on_selection_changed(0)
	visible = true


func close() -> void:
	visible = false


func _on_selection_changed(_index: int = 0) -> void:
	_validate_and_update_estimate()


func _validate_and_update_estimate() -> void:
	var origin_id := _get_selected_origin()
	var dest_id := _get_selected_destination()
	var cargo_id := _get_selected_cargo()

	if origin_id.is_empty() or dest_id.is_empty() or cargo_id.is_empty():
		_estimate_label.text = "Select all fields"
		_create_btn.disabled = true
		return

	if origin_id == dest_id:
		_estimate_label.text = "Origin and destination must differ"
		_create_btn.disabled = true
		return

	if _route_toy == null:
		_estimate_label.text = "—"
		_create_btn.disabled = true
		return

	var train_idx := _get_selected_train_index()

	# Check path via route_toy
	var est: Dictionary = _route_toy.get_path_estimate(origin_id, dest_id, train_idx, cargo_id)
	if not est.valid:
		_estimate_label.text = "No track connection"
		_warnings_label.text = ""
		_create_btn.disabled = true
		return

	var dest_price: float = est.dest_price
	var capacity: int = est.train_capacity_units
	var revenue: int = est.revenue_estimate
	var maintenance: int = est.maintenance_per_day
	var net: int = revenue - maintenance

	_estimate_label.text = "Distance: %.1f km | Capacity: %d units\nRevenue: ₹%s | Maint: ₹%s/day | Net: %s₹%s" % [
		est.distance_km, capacity,
		_comma_sep(revenue), _comma_sep(maintenance),
		"+" if net >= 0 else "", _comma_sep(abs(net))
	]

	# Warnings
	var warnings: Array[String] = []
	if est.origin_stock < capacity and capacity > 0:
		warnings.append("Low stock: only %d available" % est.origin_stock)
	if est.demand_ratio < 0.8:
		warnings.append("Shortage: high prices!")
	elif est.demand_ratio > 1.2:
		warnings.append("Oversupply: low prices")
	_warnings_label.text = " | ".join(warnings) if not warnings.is_empty() else ""

	_create_btn.disabled = false


func _get_selected_train_index() -> int:
	var idx := _train_option.selected
	if idx < 0 or idx >= _train_option.item_count:
		return 0
	return _train_option.get_item_metadata(idx) as int


func _get_selected_origin() -> String:
	var idx := _origin_option.selected
	if idx < 0 or idx >= _origin_option.item_count:
		return ""
	return _origin_option.get_item_metadata(idx) as String


func _get_selected_destination() -> String:
	var idx := _destination_option.selected
	if idx < 0 or idx >= _destination_option.item_count:
		return ""
	return _destination_option.get_item_metadata(idx) as String


func _get_selected_cargo() -> String:
	var idx := _cargo_option.selected
	if idx < 0 or idx >= _cargo_option.item_count:
		return ""
	return _cargo_option.get_item_metadata(idx) as String


func _on_create() -> void:
	var params := {
		"train_index": _get_selected_train_index(),
		"origin_city_id": _get_selected_origin(),
		"destination_city_id": _get_selected_destination(),
		"cargo_id": _get_selected_cargo(),
		"loop_enabled": _loop_check.button_pressed,
		"return_empty": _return_empty_check.button_pressed,
	}
	route_created.emit(params)
	close()


func _on_cancel() -> void:
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
