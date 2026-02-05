class_name RestRoom extends Node2D

signal ready_to_fight()

@onready var background: Sprite2D = $Background
@onready var ready_button: Button = %ReadyButton

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var upgrades: Node2D = %Upgrades
@export var upgrade_parts : Array[Anatomy]

func _ready() -> void:
	ready_button.pressed.connect(leave_rest_room)
	leave_rest_room()

func enter_rest_room() -> void:
	player.rest_mode = true
	background.visible = true
	ready_button.visible = true
	ready_button.mouse_filter = Control.MOUSE_FILTER_STOP
	audio.muffle(true, false)
	connect_parts_interact_signal()
	for part in player.anatomy_parts:
		if part.state == Anatomy.PartState.DESTROYED:
			part.state = Anatomy.PartState.OutOfBody
			part.body_owner = null

func leave_rest_room() -> void:
	background.visible = false
	ready_button.visible = false
	ready_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	audio.muffle(true, true)
	for i in range(player.anatomy_parts.size() - 1, -1, -1):
		var part = player.anatomy_parts[i]
		if part.body_owner == null or part.state == Anatomy.PartState.OutOfBody:
			part.queue_free()
			player.anatomy_parts.remove_at(i)
	if player.anatomy_parts.is_empty():
		assert("can't start")
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
