class_name TrainPurchasePanel
extends PanelContainer


signal train_purchased(train_id: String, city_id: String)
signal cancelled

@onready var _title_label: Label = %TitleLabel
@onready var _train_option: OptionButton = %TrainOption
@onready var _city_option: OptionButton = %CityOption
@onready var _cost_label: Label = %CostLabel
@onready var _buy_btn: Button = %BuyButton
@onready var _cancel_btn: Button = %CancelButton

var _train_catalog: Dictionary = {}
var _city_names: Dictionary = {}
var _treasury_balance: int = 0


func _ready() -> void:
	_buy_btn.pressed.connect(_on_buy)
	_cancel_btn.pressed.connect(_on_cancel)
	_train_option.item_selected.connect(_on_train_selected)
	visible = false


func open(train_catalog: Dictionary, city_names: Dictionary, treasury_balance: int) -> void:
	_train_catalog = train_catalog
	_city_names = city_names
	_treasury_balance = treasury_balance

	_train_option.clear()
	for train_id in train_catalog.keys():
		var t_data: TrainData = train_catalog[train_id]
		_train_option.add_item("%s (₹%s)" % [t_data.display_name, _comma_sep(t_data.cost)])
		_train_option.set_item_metadata(_train_option.item_count - 1, train_id)

	_city_option.clear()
	for city_id in city_names.keys():
		_city_option.add_item(city_names[city_id])
		_city_option.set_item_metadata(_city_option.item_count - 1, city_id)

	_update_cost()
	visible = true


func close() -> void:
	visible = false


func _on_train_selected(_index: int) -> void:
	_update_cost()


func _update_cost() -> void:
	var train_id: String = _get_selected_train_id()
	var t_data: TrainData = _train_catalog.get(train_id, null) as TrainData
	if t_data == null:
		_cost_label.text = "Cost: —"
		_buy_btn.disabled = true
		return

	_cost_label.text = "Cost: ₹%s" % _comma_sep(t_data.cost)
	_buy_btn.disabled = t_data.cost > _treasury_balance


func _get_selected_train_id() -> String:
	var idx := _train_option.selected
	if idx < 0 or idx >= _train_option.item_count:
		return ""
	return _train_option.get_item_metadata(idx) as String


func _get_selected_city_id() -> String:
	var idx := _city_option.selected
	if idx < 0 or idx >= _city_option.item_count:
		return ""
	return _city_option.get_item_metadata(idx) as String


func _on_buy() -> void:
	var train_id := _get_selected_train_id()
	var city_id := _get_selected_city_id()
	if train_id.is_empty() or city_id.is_empty():
		return
	train_purchased.emit(train_id, city_id)
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
