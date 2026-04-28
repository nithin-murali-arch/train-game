class_name StationUpgradePanel
extends PanelContainer


signal upgrade_purchased(city_id: String, upgrade_type: String)
signal cancelled

@onready var _title_label: Label = %TitleLabel
@onready var _city_option: OptionButton = %CityOption
@onready var _warehouse_label: Label = %WarehouseLabel
@onready var _warehouse_btn: Button = %WarehouseButton
@onready var _loading_bay_label: Label = %LoadingBayLabel
@onready var _loading_bay_btn: Button = %LoadingBayButton
@onready var _maintenance_shed_label: Label = %MaintenanceShedLabel
@onready var _maintenance_shed_btn: Button = %MaintenanceShedButton
@onready var _close_btn: Button = %CloseButton

var _route_toy: Node


func _ready() -> void:
	_city_option.item_selected.connect(_on_city_changed)
	_warehouse_btn.pressed.connect(func(): _on_upgrade("warehouse"))
	_loading_bay_btn.pressed.connect(func(): _on_upgrade("loading_bay"))
	_maintenance_shed_btn.pressed.connect(func(): _on_upgrade("maintenance_shed"))
	_close_btn.pressed.connect(_on_close)
	visible = false


func open(route_toy_ref: Node) -> void:
	_route_toy = route_toy_ref
	_populate_cities()
	_refresh()
	visible = true


func close() -> void:
	visible = false


func _populate_cities() -> void:
	_city_option.clear()
	if _route_toy == null:
		return
	var city_names: Dictionary = _route_toy.get_city_display_names() if _route_toy.has_method("get_city_display_names") else {}
	var idx := 0
	for city_id in city_names.keys():
		_city_option.add_item(city_names[city_id])
		_city_option.set_item_metadata(idx, city_id)
		idx += 1


func _refresh() -> void:
	var city_id := _get_selected_city_id()
	if city_id.is_empty() or _route_toy == null:
		_warehouse_label.text = "—"
		_warehouse_btn.disabled = true
		_loading_bay_label.text = "—"
		_loading_bay_btn.disabled = true
		_maintenance_shed_label.text = "—"
		_maintenance_shed_btn.disabled = true
		return

	var upgrades: StationUpgradeState = _route_toy.station_upgrades.get(city_id, null) as StationUpgradeState
	if upgrades == null:
		upgrades = StationUpgradeState.new()

	# Warehouse
	_warehouse_label.text = "Level: %d / 3" % upgrades.warehouse_level
	if upgrades.can_upgrade_warehouse():
		var cost: int = upgrades.get_warehouse_cost()
		if _route_toy.faction_manager != null:
			cost = _route_toy.faction_manager.apply_station_cost_discount(cost)
		_warehouse_btn.text = "Upgrade (₹%s)" % _comma_sep(cost)
		_warehouse_btn.disabled = not _route_toy.treasury.can_afford(cost)
	else:
		_warehouse_btn.text = "Max Level"
		_warehouse_btn.disabled = true

	# Loading Bay
	_loading_bay_label.text = "Level: %d / 3" % upgrades.loading_bay_level
	if upgrades.can_upgrade_loading_bay():
		var cost: int = upgrades.get_loading_bay_cost()
		if _route_toy.faction_manager != null:
			cost = _route_toy.faction_manager.apply_station_cost_discount(cost)
		_loading_bay_btn.text = "Upgrade (₹%s)" % _comma_sep(cost)
		_loading_bay_btn.disabled = not _route_toy.treasury.can_afford(cost)
	else:
		_loading_bay_btn.text = "Max Level"
		_loading_bay_btn.disabled = true

	# Maintenance Shed
	_maintenance_shed_label.text = "Level: %d / 3 | Discount: %d%%" % [upgrades.maintenance_shed_level, int(upgrades.get_maintenance_discount() * 100.0)]
	if upgrades.can_upgrade_maintenance_shed():
		var cost: int = upgrades.get_maintenance_shed_cost()
		if _route_toy.faction_manager != null:
			cost = _route_toy.faction_manager.apply_station_cost_discount(cost)
		_maintenance_shed_btn.text = "Upgrade (₹%s)" % _comma_sep(cost)
		_maintenance_shed_btn.disabled = not _route_toy.treasury.can_afford(cost)
	else:
		_maintenance_shed_btn.text = "Max Level"
		_maintenance_shed_btn.disabled = true


func _get_selected_city_id() -> String:
	var idx := _city_option.selected
	if idx < 0 or idx >= _city_option.item_count:
		return ""
	return _city_option.get_item_metadata(idx) as String


func _on_city_changed(_index: int) -> void:
	_refresh()


func _on_upgrade(upgrade_type: String) -> void:
	var city_id := _get_selected_city_id()
	if city_id.is_empty() or _route_toy == null:
		return

	var upgrades: StationUpgradeState = _route_toy.station_upgrades.get(city_id, null) as StationUpgradeState
	if upgrades == null:
		return

	var cost: int = 0
	var ok := false
	match upgrade_type:
		"warehouse":
			cost = upgrades.get_warehouse_cost()
			if _route_toy.faction_manager != null:
				cost = _route_toy.faction_manager.apply_station_cost_discount(cost)
			if _route_toy.treasury.can_afford(cost):
				_route_toy.treasury.spend(cost)
				ok = upgrades.upgrade_warehouse()
		"loading_bay":
			cost = upgrades.get_loading_bay_cost()
			if _route_toy.faction_manager != null:
				cost = _route_toy.faction_manager.apply_station_cost_discount(cost)
			if _route_toy.treasury.can_afford(cost):
				_route_toy.treasury.spend(cost)
				ok = upgrades.upgrade_loading_bay()
		"maintenance_shed":
			cost = upgrades.get_maintenance_shed_cost()
			if _route_toy.faction_manager != null:
				cost = _route_toy.faction_manager.apply_station_cost_discount(cost)
			if _route_toy.treasury.can_afford(cost):
				_route_toy.treasury.spend(cost)
				ok = upgrades.upgrade_maintenance_shed()

	if ok:
		upgrade_purchased.emit(city_id, upgrade_type)
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
