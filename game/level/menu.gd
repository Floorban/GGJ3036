extends Node2D

@export var level_scene: PackedScene

@onready var control: Control = %Control
@onready var btn_start: TextureButton = %BtnStart
@onready var btn_control: TextureButton = %BtnControl
@onready var btn_credits: TextureButton = %BtnCredits

@onready var page_control: TextureRect = %PageControl
@onready var page_credits: TextureRect = %PageCredits

@onready var bg_1: TextureRect = %BG1
@onready var bg_2: TextureRect = %BG2

func _ready() -> void:
	btn_start.pressed.connect(start_game)
	btn_control.pressed.connect(set_control_page)
	btn_credits.pressed.connect(set_credits_page)

func start_game() -> void:
	control.visible = false
	page_control.visible = false
	page_credits.visible = false
	btn_start.disabled = true
	btn_start.visible = false
	btn_start.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn_control.disabled = true
	btn_control.visible = false
	btn_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn_credits.disabled = true
	btn_credits.visible = false
	btn_credits.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var level := level_scene.instantiate()
	add_child(level)
	if level is Level:
		level.game_end.connect(end_game)

func end_game() -> void:
	bg_1.visible = false
	bg_2.visible = true
	control.visible = true
	btn_start.disabled = false
	btn_start.visible = true
	btn_control.disabled = false
	btn_control.visible = true
	btn_credits.disabled = false
	btn_credits.visible = true
	btn_start.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_control.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_credits.mouse_filter = Control.MOUSE_FILTER_STOP

func set_control_page() -> void:
	page_control.visible = !page_control.visible
	page_credits.visible = false

func set_credits_page() -> void:
	page_credits.visible = !page_credits.visible
	page_control.visible = false
