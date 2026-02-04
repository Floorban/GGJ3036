class_name RestRoom extends Node2D

signal ready_to_fight()

@onready var background: Sprite2D = $Background
@onready var ready_button: Button = %ReadyButton

func _ready() -> void:
	ready_button.pressed.connect(leave_rest_room)
	leave_rest_room()

func enter_rest_room() -> void:
	background.visible = true
	ready_button.visible = true
	ready_button.mouse_filter = Control.MOUSE_FILTER_STOP

func leave_rest_room() -> void:
	background.visible = false
	ready_button.visible = false
	ready_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ready_to_fight.emit()
