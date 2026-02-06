class_name RestRoom extends Node2D

signal ready_to_fight()

@onready var background: Sprite2D = $Background
@onready var ready_button: Button = %ReadyButton

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var upgrades: Node2D = %Upgrades
@export var upgrade_parts : Array[Anatomy]

func _ready() -> void:
	Stats.rest_room = self
	ready_button.pressed.connect(leave_rest_room)
	leave_rest_room()

func enter_rest_room() -> void:
	part_info_panel.visible = true
	player.rest_mode = true
	background.visible = true
	ready_button.visible = true
	ready_button.mouse_filter = Control.MOUSE_FILTER_STOP
	audio.muffle(true, false)
	connect_parts_interact_signal()
	for p in background.get_children():
		p.z_index = 10
	for part in player.anatomy_parts:
		if part.state == Anatomy.PartState.DESTROYED:
			part.body_owner = null

func leave_rest_room() -> void:
	part_info_panel.visible = false
	#background.visible = false
	ready_button.visible = false
	ready_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	audio.muffle(true, true)
	for i in range(player.anatomy_parts.size() - 1, -1, -1):
		var part = player.anatomy_parts[i]
		if part.body_owner == null or part.state == Anatomy.PartState.OutOfBody or part.state == Anatomy.PartState.DESTROYED:
			part.reparent(background)
			player.anatomy_parts.remove_at(i)
	if player.anatomy_parts.is_empty():
		assert(player.anatomy_parts.is_empty(), "can't start with no parts")
		return
	player.rest_mode = false
	ready_to_fight.emit()

func connect_parts_interact_signal() -> void:
	upgrade_parts.clear()
	for u in upgrades.get_children():
		if u is Anatomy:
			u.state = Anatomy.PartState.OutOfBody
			upgrade_parts.append(u)
	if upgrade_parts.is_empty():
		return
	for part in upgrade_parts:
		if not part.anatomy_clicked.is_connected(player._on_self_anatomy_clicked):
			part.anatomy_clicked.connect(player._on_self_anatomy_clicked)

@onready var part_info_panel: MarginContainer = $CanvasLayer/PartInfoPanel
@onready var label_part_name: Label = %LabelPartName
@onready var label_part_state: Label = %LabelPartState
@onready var bar_part_hp: TextureProgressBar = %BarPartHP
@onready var stat_labels: Array[Label] = [%LabelPartStat1, %LabelPartStat2, %LabelPartStat3]

func show_part_info(_name: String, _state: String, _hp: float, _max_hp: float, _stats: Array[String]) -> void:
	if not part_info_panel.visible:
		return
	
	label_part_name.text = _name
	label_part_state.text = _state
	bar_part_hp.max_value = _max_hp
	bar_part_hp.value = _hp

	for i in min(_stats.size(), stat_labels.size()):
		stat_labels[i].text = _stats[i]

func hide_part_info() -> void:
	label_part_name.text = ""
	label_part_state.text =  ""
	bar_part_hp.max_value = 1
	bar_part_hp.value = 0
	for label in stat_labels:
		label.text = ""
