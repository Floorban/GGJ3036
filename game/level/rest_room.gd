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
	connect_parts_interact_signal()

func leave_rest_room() -> void:
	player.rest_mode = false
	background.visible = false
	ready_button.visible = false
	ready_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
		part.anatomy_clicked.connect(player._on_self_anatomy_clicked)
