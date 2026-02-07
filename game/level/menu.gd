extends Node2D

@export var level_scene: PackedScene

@onready var btn_start: Button = %BtnStart

func _ready() -> void:
	btn_start.pressed.connect(start_game)

func start_game() -> void:
	btn_start.disabled = true
	btn_start.visible = false
	btn_start.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var level := level_scene.instantiate()
	add_child(level)
	if level is Level:
		level.game_end.connect(end_game)

func end_game() -> void:
	btn_start.disabled = false
	btn_start.visible = true
	btn_start.mouse_filter = Control.MOUSE_FILTER_STOP
