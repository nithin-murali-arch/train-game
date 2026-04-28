class_name EventLogPanel
extends PanelContainer


signal closed

@onready var _title_label: Label = %TitleLabel
@onready var _warnings_list: VBoxContainer = %WarningsList
@onready var _active_list: VBoxContainer = %ActiveList
@onready var _resolved_list: VBoxContainer = %ResolvedList
@onready var _close_btn: Button = %CloseButton

var _event_manager: EventManager = null
var current_absolute_day: int = 0


func _ready() -> void:
	_close_btn.pressed.connect(_on_close)
	visible = false


func open(event_manager: EventManager) -> void:
	_event_manager = event_manager
	refresh()
	visible = true


func close() -> void:
	visible = false


func refresh() -> void:
	_clear_list(_warnings_list)
	_clear_list(_active_list)
	_clear_list(_resolved_list)

	if _event_manager == null:
		_add_empty_label(_warnings_list, "No warnings")
		_add_empty_label(_active_list, "No active events")
		_add_empty_label(_resolved_list, "No recent events")
		return

	# Warnings
	var warnings: Array[EventRuntimeState] = _event_manager.get_warning_events()
	for event in warnings:
		var row := _create_event_row(event)
		_warnings_list.add_child(row)
	if _warnings_list.get_child_count() == 0:
		_add_empty_label(_warnings_list, "No warnings")

	# Active events
	var active: Array[EventRuntimeState] = _event_manager.get_active_events()
	for event in active:
		var row := _create_event_row(event)
		_active_list.add_child(row)
	if _active_list.get_child_count() == 0:
		_add_empty_label(_active_list, "No active events")

	# Recent resolved
	var resolved: Array[EventRuntimeState] = _event_manager.get_recent_resolved()
	for event in resolved:
		var row := _create_event_row(event)
		_resolved_list.add_child(row)
	if _resolved_list.get_child_count() == 0:
		_add_empty_label(_resolved_list, "No recent events")


func _clear_list(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()


func _add_empty_label(container: VBoxContainer, text: String) -> void:
	var empty := Label.new()
	empty.text = text
	container.add_child(empty)


func _create_event_row(event: EventRuntimeState) -> Control:
	var panel := PanelContainer.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	margin.add_child(vbox)

	# Title row with severity color
	var title := Label.new()
	title.text = "%s — %s" % [event.display_name, event.get_status_name()]
	title.add_theme_font_size_override("font_size", 14)
	vbox.add_child(title)

	# Affected targets
	var targets := _build_targets_text(event)
	if not targets.is_empty():
		var targets_label := Label.new()
		targets_label.text = targets
		vbox.add_child(targets_label)

	# Days remaining (for warning and active)
	if event.status == EventRuntimeState.Status.WARNING or event.status == EventRuntimeState.Status.ACTIVE:
		var days_label := Label.new()
		days_label.text = _get_days_text(event)
		vbox.add_child(days_label)

	# Description
	var desc := Label.new()
	desc.text = event.description
	desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(desc)

	# Severity indicator
	var severity_label := Label.new()
	severity_label.text = _severity_text(event.severity)
	severity_label.add_theme_color_override("font_color", _severity_color(event.severity))
	vbox.add_child(severity_label)

	return panel


func _build_targets_text(event: EventRuntimeState) -> String:
	var parts: Array[String] = []
	if not event.affected_city_id.is_empty():
		parts.append("City: %s" % event.affected_city_id.capitalize())
	if not event.affected_cargo_id.is_empty():
		parts.append("Cargo: %s" % event.affected_cargo_id.capitalize())
	if event.affected_edge_from != event.affected_edge_to:
		parts.append("Edge: (%d, %d) → (%d, %d)" % [
			event.affected_edge_from.x, event.affected_edge_from.y,
			event.affected_edge_to.x, event.affected_edge_to.y
		])
	return " | ".join(parts)


func _get_days_text(event: EventRuntimeState) -> String:
	if current_absolute_day <= 0:
		return ""
	if event.status == EventRuntimeState.Status.WARNING:
		var days_until := event.start_absolute_day - current_absolute_day
		return "Starts in %d day(s)" % maxi(days_until, 0)
	elif event.status == EventRuntimeState.Status.ACTIVE:
		var days_left := event.end_absolute_day - current_absolute_day
		return "%d day(s) remaining" % maxi(days_left, 0)
	return ""


func _severity_text(severity: int) -> String:
	match severity:
		1: return "Severity: Low"
		2: return "Severity: Moderate"
		3: return "Severity: High"
		_: return "Severity: Unknown"


func _severity_color(severity: int) -> Color:
	match severity:
		1: return Color(0.9, 0.9, 0.3)  # Yellow
		2: return Color(0.9, 0.5, 0.2)  # Orange
		3: return Color(0.9, 0.2, 0.2)  # Red
		_: return Color(0.7, 0.7, 0.7)


func _on_close() -> void:
	closed.emit()
	close()
