class_name RouteToyHUD
extends CanvasLayer


@onready var _company_label: Label = %CompanyLabel
@onready var _treasury_label: Label = %TreasuryLabel
@onready var _date_label: Label = %DateLabel
@onready var _reputation_label: Label = %ReputationLabel

@onready var _pause_btn: Button = %PauseButton
@onready var _speed_1x_btn: Button = %Speed1xButton
@onready var _speed_2x_btn: Button = %Speed2xButton
@onready var _speed_4x_btn: Button = %Speed4xButton
@onready var _advance_day_btn: Button = %AdvanceDayButton

@onready var _route_status_label: Label = %RouteStatusLabel
@onready var _route_name_label: Label = %RouteNameLabel
@onready var _cargo_label: Label = %CargoLabel
@onready var _trips_label: Label = %TripsLabel

@onready var _dest_price_label: Label = %DestPriceLabel
@onready var _origin_stock_label: Label = %OriginStockLabel
@onready var _dest_stock_label: Label = %DestStockLabel
@onready var _demand_label: Label = %DemandLabel

@onready var _next_route_btn: Button = %NextRouteButton
@onready var _route_counter_label: Label = %RouteCounterLabel

@onready var _last_revenue_label: Label = %LastRevenueLabel
@onready var _last_cost_label: Label = %LastCostLabel
@onready var _last_profit_label: Label = %LastProfitLabel
@onready var _total_revenue_label: Label = %TotalRevenueLabel
@onready var _total_cost_label: Label = %TotalCostLabel
@onready var _total_profit_label: Label = %TotalProfitLabel

@onready var _build_track_btn: Button = %BuildTrackButton
@onready var _buy_train_btn: Button = %BuyTrainButton
@onready var _create_route_btn: Button = %CreateRouteButton
@onready var _contracts_btn: Button = %ContractsButton
@onready var _stations_btn: Button = %StationsButton
@onready var _start_btn: Button = %StartButton
@onready var _pause_resume_btn: Button = %PauseResumeButton
@onready var _reset_btn: Button = %ResetButton

@onready var _train_purchase_panel: Node = %TrainPurchasePanel
@onready var _route_creation_panel: Node = %RouteCreationPanel
@onready var _contracts_panel: Node = %ContractsPanel
@onready var _station_upgrade_panel: Node = %StationUpgradePanel

var _route_toy: Node
var _selected_route_index: int = 0
var _last_trip_count: int = -1
var _last_state_name: String = ""

var _toast_label: Label
var _toast_timer: float = 0.0


func bind_route_toy(route_toy: Node) -> void:
	_route_toy = route_toy
	# Disconnect old runner signals if any
	_disconnect_all_runner_signals()
	# Connect to ALL runners
	for r in route_toy.active_runners:
		_connect_runner_signals(r)
	_selected_route_index = 0
	_update_all()


func _connect_runner_signals(runner: RouteRunner) -> void:
	if not runner.state_changed.is_connected(_on_state_changed):
		runner.state_changed.connect(_on_state_changed)
	if not runner.trip_completed.is_connected(_on_trip_completed):
		runner.trip_completed.connect(_on_trip_completed)
	if not runner.route_failed.is_connected(_on_route_failed):
		runner.route_failed.connect(_on_route_failed)


func _disconnect_runner_signals(runner: RouteRunner) -> void:
	if runner == null:
		return
	if runner.state_changed.is_connected(_on_state_changed):
		runner.state_changed.disconnect(_on_state_changed)
	if runner.trip_completed.is_connected(_on_trip_completed):
		runner.trip_completed.disconnect(_on_trip_completed)
	if runner.route_failed.is_connected(_on_route_failed):
		runner.route_failed.disconnect(_on_route_failed)


func _disconnect_all_runner_signals() -> void:
	if _route_toy == null:
		return
	for r in _route_toy.active_runners:
		_disconnect_runner_signals(r)


func _ready() -> void:
	_pause_btn.pressed.connect(func(): _route_toy.set_speed_preset("pause"))
	_speed_1x_btn.pressed.connect(func(): _route_toy.set_speed_preset("1x"))
	_speed_2x_btn.pressed.connect(func(): _route_toy.set_speed_preset("2x"))
	_speed_4x_btn.pressed.connect(func(): _route_toy.set_speed_preset("4x"))
	_advance_day_btn.pressed.connect(func(): _route_toy.advance_one_day())

	_build_track_btn.pressed.connect(func(): _route_toy.toggle_build_mode())
	_buy_train_btn.pressed.connect(_on_buy_train_pressed)
	_create_route_btn.pressed.connect(_on_create_route_pressed)
	_contracts_btn.pressed.connect(_on_contracts_pressed)
	_stations_btn.pressed.connect(_on_stations_pressed)
	_next_route_btn.pressed.connect(_on_next_route_pressed)

	_start_btn.pressed.connect(func(): _route_toy.start_route())
	_pause_resume_btn.pressed.connect(func(): _route_toy.pause_resume())
	_reset_btn.pressed.connect(func(): _on_reset_pressed())

	if _train_purchase_panel != null:
		_train_purchase_panel.train_purchased.connect(_on_train_purchased)
		_train_purchase_panel.cancelled.connect(func(): close_panels())

	if _route_creation_panel != null:
		_route_creation_panel.route_created.connect(_on_route_created)
		_route_creation_panel.cancelled.connect(func(): close_panels())

	if _contracts_panel != null:
		_contracts_panel.contract_accepted.connect(_on_contract_accepted)
		_contracts_panel.cancelled.connect(func(): close_panels())

	if _station_upgrade_panel != null:
		_station_upgrade_panel.upgrade_purchased.connect(_on_upgrade_purchased)
		_station_upgrade_panel.cancelled.connect(func(): close_panels())


func close_panels() -> void:
	if _train_purchase_panel != null:
		_train_purchase_panel.close()
	if _route_creation_panel != null:
		_route_creation_panel.close()
	if _contracts_panel != null:
		_contracts_panel.close()
	if _station_upgrade_panel != null:
		_station_upgrade_panel.close()


func _process(delta: float) -> void:
	if _route_toy == null:
		return
	_update_treasury_date()
	_update_city_info()
	_update_trip_stats()
	_update_speed_buttons()
	_update_toast(delta)


# ------------------------------------------------------------------------------
# Signal handlers
# ------------------------------------------------------------------------------

func _on_state_changed(_new_state: String) -> void:
	_update_route_info()


func _on_trip_completed(_stats: RouteProfitStats) -> void:
	_update_trip_stats()


func _on_route_failed(reason: String) -> void:
	_route_status_label.text = "Status: FAILED — %s" % reason


func _on_reset_pressed() -> void:
	_disconnect_all_runner_signals()
	_route_toy.reset_simulation()
	close_panels()
	_selected_route_index = 0
	_last_trip_count = -1
	_last_state_name = ""
	_update_all()


func _on_buy_train_pressed() -> void:
	if _route_toy == null or _train_purchase_panel == null:
		return
	var catalog: Dictionary = _route_toy.get_train_catalog()
	var cities: Dictionary = _route_toy.get_city_display_names()
	var balance: int = _route_toy.get_treasury_balance()
	_train_purchase_panel.open(catalog, cities, balance)


func _on_create_route_pressed() -> void:
	if _route_toy == null or _route_creation_panel == null:
		return
	var train_names: Array[String] = _route_toy.get_train_display_names()
	if train_names.is_empty():
		show_toast("Buy a train first")
		return
	var cities: Dictionary = _route_toy.get_city_display_names()
	var cargo_ids: Array[String] = _route_toy.get_cargo_ids()
	_route_creation_panel.open(train_names, cities, cargo_ids, _route_toy)


func _on_train_purchased(train_id: String, city_id: String) -> void:
	if _route_toy != null:
		_route_toy.purchase_train(train_id, city_id)


func _on_route_created(params: Dictionary) -> void:
	if _route_toy != null:
		_route_toy.create_route(params)
		# Connect signals to the newly added runner
		var new_runner = _route_toy.get_runner_by_index(_route_toy.get_runner_count() - 1)
		if new_runner != null:
			_connect_runner_signals(new_runner)
		# Auto-select the new route
		_selected_route_index = _route_toy.get_runner_count() - 1
		_update_all()


func _on_contracts_pressed() -> void:
	if _route_toy == null or _contracts_panel == null:
		return
	close_panels()
	_contracts_panel.open(_route_toy)


func _on_stations_pressed() -> void:
	if _route_toy == null or _station_upgrade_panel == null:
		return
	close_panels()
	_station_upgrade_panel.open(_route_toy)


func _on_contract_accepted(_contract_id: String) -> void:
	show_toast("Contract accepted")


func _on_upgrade_purchased(_city_id: String, _upgrade_type: String) -> void:
	show_toast("Upgrade purchased")


func _on_next_route_pressed() -> void:
	var count: int = _route_toy.get_runner_count()
	if count <= 1:
		return
	_selected_route_index = (_selected_route_index + 1) % count
	_update_all()


func _selected_runner() -> RouteRunner:
	if _route_toy == null:
		return null
	return _route_toy.get_runner_by_index(_selected_route_index)


func _selected_schedule() -> RouteSchedule:
	var r: RouteRunner = _selected_runner()
	if r == null:
		return null
	return r._schedule


# ------------------------------------------------------------------------------
# Update helpers
# ------------------------------------------------------------------------------

func _update_all() -> void:
	_update_treasury_date()
	_update_route_info()
	_update_city_info()
	_update_trip_stats()
	_update_speed_buttons()


func _update_treasury_date() -> void:
	_treasury_label.text = "Treasury: ₹%s" % _comma_sep(_route_toy.get_treasury_balance())
	_date_label.text = "Date: %s" % _route_toy.get_date_string()
	var rep: int = _route_toy.reputation if _route_toy != null else 0
	_reputation_label.text = "Reputation: %d" % rep


func _update_route_info() -> void:
	var runner = _selected_runner()
	var state := "No route"
	if runner != null:
		state = runner.get_state_name()
	if state != _last_state_name:
		_last_state_name = state
		_route_status_label.text = "Status: %s" % state

	var count: int = _route_toy.get_runner_count()
	if count > 0:
		_route_counter_label.text = "Route %d / %d" % [_selected_route_index + 1, count]
	else:
		_route_counter_label.text = "Route 0 / 0"

	var sched: RouteSchedule = _selected_schedule()
	if sched != null:
		var origin_data: CityData = _route_toy.city_data_by_id.get(sched.origin_city_id, null) as CityData
		var dest_data: CityData = _route_toy.city_data_by_id.get(sched.destination_city_id, null) as CityData
		var origin_str := origin_data.display_name if origin_data != null else sched.origin_city_id
		var dest_str := dest_data.display_name if dest_data != null else sched.destination_city_id
		_route_name_label.text = "Route: %s → %s" % [origin_str, dest_str]
		_cargo_label.text = "Cargo: %s" % sched.cargo_id.capitalize()
	else:
		_route_name_label.text = "Route: —"
		_cargo_label.text = "Cargo: —"


func _update_city_info() -> void:
	var sched: RouteSchedule = _selected_schedule()
	if sched == null:
		_dest_price_label.text = "Dest Price: —"
		_origin_stock_label.text = "Origin Stock: —"
		_dest_stock_label.text = "Dest Stock: —"
		_demand_label.text = "Demand: —"
		return

	var origin_id: String = sched.origin_city_id
	var dest_id: String = sched.destination_city_id
	var cargo_id: String = sched.cargo_id

	var price: float = _route_toy.get_sell_price(dest_id, cargo_id)
	var origin_stock: int = _route_toy.get_city_stock(origin_id, cargo_id)
	var dest_stock: int = _route_toy.get_city_stock(dest_id, cargo_id)
	var demand: String = _route_toy.get_demand_label(dest_id, cargo_id)

	_dest_price_label.text = "Dest Price: ₹%.0f" % price
	_origin_stock_label.text = "Origin Stock: %s" % _comma_sep(origin_stock)
	_dest_stock_label.text = "Dest Stock: %s" % _comma_sep(dest_stock)
	_demand_label.text = "Demand: %s" % demand


func _update_trip_stats() -> void:
	var runner: RouteRunner = _selected_runner()
	var stats: RouteProfitStats = null
	if runner != null:
		stats = runner.get_stats()
	if stats == null:
		_trips_label.text = "Trips: 0"
		_last_revenue_label.text = "Last Revenue: ₹0"
		_last_cost_label.text = "Last Cost: ₹0"
		_last_profit_label.text = "Last Profit: ₹0"
		_total_revenue_label.text = "Total Revenue: ₹0"
		_total_cost_label.text = "Total Cost: ₹0"
		_total_profit_label.text = "Total Profit: ₹0"
		return

	if stats.trips_completed != _last_trip_count:
		_last_trip_count = stats.trips_completed
		_trips_label.text = "Trips: %d" % stats.trips_completed

	_last_revenue_label.text = "Last Revenue: ₹%s" % _comma_sep(stats.last_trip_revenue)
	_last_cost_label.text = "Last Cost: ₹%s" % _comma_sep(stats.last_trip_operating_cost)
	_last_profit_label.text = "Last Profit: ₹%s" % _comma_sep(stats.last_trip_profit)
	_total_revenue_label.text = "Total Revenue: ₹%s" % _comma_sep(stats.total_revenue)
	_total_cost_label.text = "Total Cost: ₹%s" % _comma_sep(stats.total_operating_cost)
	_total_profit_label.text = "Total Profit: ₹%s" % _comma_sep(stats.total_profit)


func _update_speed_buttons() -> void:
	var paused: bool = _route_toy.is_clock_paused()
	_pause_resume_btn.text = "Resume" if paused else "Pause"

	_pause_btn.disabled = paused
	_speed_1x_btn.disabled = not paused
	_speed_2x_btn.disabled = not paused
	_speed_4x_btn.disabled = not paused


func show_toast(message: String, duration: float = 2.0) -> void:
	if _toast_label == null:
		_toast_label = Label.new()
		_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_toast_label.add_theme_font_size_override("font_size", 18)
		var panel := PanelContainer.new()
		panel.add_child(_toast_label)
		panel.anchors_preset = Control.PRESET_CENTER_TOP
		panel.offset_top = 80
		panel.offset_left = -150
		panel.offset_right = 150
		panel.offset_bottom = 120
		panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
		add_child(panel)
	_toast_label.text = message
	_toast_label.get_parent().visible = true
	_toast_timer = duration


func _update_toast(delta: float) -> void:
	if _toast_timer > 0.0:
		_toast_timer -= delta
		if _toast_timer <= 0.0 and _toast_label != null:
			_toast_label.get_parent().visible = false


func _comma_sep(n: int) -> String:
	var s := str(n)
	var result := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result
