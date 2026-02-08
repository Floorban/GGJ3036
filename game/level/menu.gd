extends Node2D

var tutorial := false
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

func intro_dialogue() -> void:
	if tutorial:
		await get_tree().create_timer(0.8).timeout
		DialogueManager.say("Let me fix your nose first come here")
		await get_tree().create_timer(1.8).timeout
		DialogueManager.say("You still remember how to punch this mf right?")
		await get_tree().create_timer(3.0).timeout
		DialogueManager.say("fucking damn it, LEFT CLICK to punch his fucking face !!")
		await get_tree().create_timer(3.0).timeout
		DialogueManager.say("Okay time to go now brother")
		await get_tree().create_timer(1.5).timeout
		DialogueManager.say("Brooootheeerrr !!!")
		await get_tree().create_timer(3.0).timeout
		DialogueManager.say("Bro wake up wake up !!!")
		await get_tree().create_timer(2.0).timeout
		DialogueManager.say("LOOOOOOOOCK", 380)
		await get_tree().create_timer(0.5).timeout
		DialogueManager.say("THE", 38)
		await get_tree().create_timer(0.5).timeout
		DialogueManager.say("FUCK", 38)	
		await get_tree().create_timer(0.5).timeout
		DialogueManager.say("INNNNNNNNNN !!!", 38)
	else:
		await get_tree().create_timer(1.0).timeout
		DialogueManager.say("Bro I gave you 2 lives and you died?")
		await get_tree().create_timer(2.0).timeout
		DialogueManager.say("The items are unbalanced at hell as well lol")
		await get_tree().create_timer(2.0).timeout
		DialogueManager.say("Anyway")
		await get_tree().create_timer(1.0).timeout
		DialogueManager.say("You noticed how each face part contribute to your stats?")
		await get_tree().create_timer(2.2).timeout
		DialogueManager.say("Same goes to your opponents")
		await get_tree().create_timer(1.2).timeout
		DialogueManager.say("Punch their biggest part first would help")
		await get_tree().create_timer(1.7).timeout
		DialogueManager.say("Alright now you know the drill")
		await get_tree().create_timer(1.5).timeout
		DialogueManager.say("Oh right just press 'R' to restart if you find any bug")
		await get_tree().create_timer(1.7).timeout
		DialogueManager.say("Good luck my brother")

func _ready() -> void:
	transition_screen.burn()
	btn_start.pressed.connect(start_game)
	btn_control.pressed.connect(set_control_page)
	btn_credits.pressed.connect(set_credits_page)

func start_game() -> void:
	transition_screen.cover()
	intro_dialogue()
	await get_tree().create_timer(15.0).timeout
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
	tutorial = false
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
