extends Node2D

@export var level_scene: PackedScene

@onready var transition_screen: transition_screen = %TransitionScreen
@onready var control: Control = %Control
@onready var btn_start: TextureButton = %BtnStart
@onready var label_start: Label = %LabelStart
@onready var btn_control: TextureButton = %BtnControl
@onready var btn_credits: TextureButton = %BtnCredits

@onready var page_control: TextureRect = %PageControl
@onready var page_credits: TextureRect = %PageCredits

@onready var bg_1: TextureRect = %BG1
@onready var bg_2: TextureRect = %BG2

func _ready() -> void:
	transition_screen.burn()
	btn_start.pressed.connect(start_game)
	btn_control.pressed.connect(set_control_page)
	btn_credits.pressed.connect(set_credits_page)

func start_game() -> void:
	transition_screen.cover()
	await get_tree().create_timer(1.5).timeout
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
	label_start.text = "TRY AGAIN"
	transition_screen.burn()
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
	page_credits.visible = false
	pop_page(page_control, !page_control.visible)

func set_credits_page() -> void:
	page_control.visible = false
	pop_page(page_credits, !page_credits.visible)

func pop_page(page: Control, show: bool) -> void:
	if show:
		page.visible = true
		page.scale = Vector2(0.8, 0.8)
		page.modulate.a = 0.0

		var tween := create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(page, "scale", Vector2.ONE, 0.35)
		tween.parallel().tween_property(page, "modulate:a", 1.0, 0.3)
	else:
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(page, "scale", Vector2(0.3, 0.3), 0.28)
		tween.parallel().tween_property(page, "modulate:a", 0.0, 0.23)
		tween.finished.connect(func():
			page.visible = false
		)
