class_name TrackPanel
extends Control


signal access_mode_changed(edge: TrackEdgeData, new_mode: String)
signal toll_changed(edge: TrackEdgeData, new_toll: float)
signal closed

@onready var _title_label: Label = %TitleLabel
@onready var _owner_label: Label = %OwnerLabel
@onready var _access_mode_label: Label = %AccessModeLabel
@onready var _toll_label: Label = %TollLabel
@onready var _length_label: Label = %LengthLabel
@onready var _condition_label: Label = %ConditionLabel
@onready var _set_open_btn: Button = %SetOpenButton
@onready var _set_private_btn: Button = %SetPrivateButton
@onready var _toll_input: LineEdit = %TollInput
@onready var _apply_toll_btn: Button = %ApplyTollButton
@onready var _close_btn: Button = %CloseButton

var _current_edge: TrackEdgeData


func _ready() -> void:
	_set_open_btn.pressed.connect(_on_set_open)
	_set_private_btn.pressed.connect(_on_set_private)
	_apply_toll_btn.pressed.connect(_on_apply_toll)
	_close_btn.pressed.connect(close)
	visible = false


func open(edge: TrackEdgeData, is_player_owned: bool) -> void:
	if edge == null:
		close()
		return

	_current_edge = edge

	_title_label.text = "Track Properties"
	_owner_label.text = "Owner: %s" % edge.owner_faction_id
	_access_mode_label.text = "Access: %s" % edge.access_mode.capitalize()
	_toll_label.text = "Toll: ₹%.2f/km" % edge.toll_per_km
	_length_label.text = "Length: %.1f km" % edge.length_km
	_condition_label.text = "Condition: %.0f%%" % (edge.condition * 100.0)
	_toll_input.text = str(edge.toll_per_km)

	var can_edit := is_player_owned
	_set_open_btn.disabled = not can_edit
	_set_private_btn.disabled = not can_edit
	_toll_input.editable = can_edit
	_apply_toll_btn.disabled = not can_edit

	visible = true


func close() -> void:
	visible = false
	_current_edge = null
	closed.emit()


func _on_set_open() -> void:
	if _current_edge == null:
		return
	_current_edge.access_mode = "open"
	_access_mode_label.text = "Access: Open"
	access_mode_changed.emit(_current_edge, "open")


func _on_set_private() -> void:
	if _current_edge == null:
		return
	_current_edge.access_mode = "private"
	_access_mode_label.text = "Access: Private"
	access_mode_changed.emit(_current_edge, "private")


func _on_apply_toll() -> void:
	if _current_edge == null:
		return
	var new_toll := _toll_input.text.to_float()
	if new_toll < 0.0:
		new_toll = 0.0
	_current_edge.toll_per_km = new_toll
	_toll_label.text = "Toll: ₹%.2f/km" % new_toll
	toll_changed.emit(_current_edge, new_toll)
