class_name Level extends Node2D

@export var first_time := true

@export var bg_textures : Array[Texture2D]

signal game_end

signal battle_start
signal battle_end

var paused := false

@onready var background: Sprite2D = %Background
@onready var rest_room: RestRoom = %RestRoom
@onready var arena_center: Marker2D = %ArenaCenter
@onready var corner: Marker2D = %Corner
@onready var rest_room_anchor: Marker2D = %RestRoomAnchor
@onready var enemies_container: Node2D = $Enemies
var start_pos : Vector2

@onready var camera: CameraController = $Camera
@onready var game_ui: GameUI = %GameUI
@onready var retro_screen: RetroScreen = %RetroScreen
var retro_mat: ShaderMaterial
@onready var transition_screen: transition_screen = %TransitionScreen
@export var battle_duration := 40.0
@export var break_duration := 15.0
var in_break := false
var in_battle := false
var battle_time_left: float

# level 0 is tutorial VS bully
@export_range(1,7) var current_level := 1
var current_round := 0
var max_round := 2
@export var first_level := true

@export var enemies: Array[Enemy]
@onready var player: Player = %Player
var enemy: Enemy

#AUDIO
var sfx_music: String = "event:/Music/Melody"
var sfx_music_boss: String = "event:/Music/DnB"
var i_music: FmodEvent
var i_music_boss: FmodEvent

var sfx_countdown: String = "event:/SFX/NPC/Coach/Count"
var sfx_ring: String = "event:/SFX/Arena/Ring"

func _ready() -> void:
	transition_screen.burn()
	game_ui.timer_panel.visible = false
	battle_time_left = 100.0
	rest_room.ready_to_fight.connect(start_battle)
	start_pos = player.position
	enemies.clear()
	for e in enemies_container.get_children():
		if e is Enemy:
			enemies.append(e)
	retro_mat = retro_screen.material as ShaderMaterial
	#init_combat_arena(current_level)
	start_battle()
	first_level = false

func init_combat_arena(level : int) -> void:
	if level >= enemies.size():
		final_stage()
	background.texture = bg_textures[level - 1]
	enemy = enemies[level - 1]
	enemy.visible = true
	player.opponent = enemy
	enemy.opponent = player
	player.init_character()
	enemy.init_character()
	if not enemy.die.is_connected(player_win):
		enemy.die.connect(player_win)
	rest_room.attached_index = 0
	if first_level:
		#current_round = 1
		player.hit.connect(_screen_shake)
		player.blocked.connect(_screen_shake)
		player.die.connect(player_lose)

	if i_music == null: i_music = audio.play_instance(sfx_music)

func final_stage() -> void:
	audio.clear_instance([i_music])
	i_music_boss = audio.play_instance(sfx_music_boss)

func start_battle() -> void:
	
	camera.switch_target(arena_center, 50)
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	

	tween.parallel().tween_property(
		enemies_container,
		"position",
		Vector2.ZERO,
		0.3
	)
	
	var current_val = retro_mat.get_shader_parameter("color_quant_steps")
	tween.tween_property(retro_mat, "shader_parameter/color_quant_steps", player.player_health_effect_value, 0.3).from(current_val)
	
	tween.tween_property(
		camera,
		"zoom",
		Vector2.ONE * 2,
		0.2
	)
	
	background.visible = true
	init_combat_arena(current_level)
	game_ui.show_boss_name(enemy.boss_name)
	player.arm.movable_by_mouse = false
	tween.tween_callback(func():
		await get_tree().create_timer(2.0).timeout
		in_battle = true
		in_break = false
		game_ui.timer_panel.visible = true
		paused = false
		battle_time_left = battle_duration
		player.get_ready_to_battle()
		enemy.get_ready_to_battle()
		battle_start.emit()
	)


func player_win() -> void:
	paused = true
	
	Engine.time_scale = 0.01

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	Engine.time_scale = 0.1

	tween.tween_method(
		func(value: float):
			Engine.time_scale = value,
		0.01,
		2.0,
		2.5
	)
	tween.tween_method(
		func(value: float):
			Engine.time_scale = value,
		2.0,
		1.0,
		0.3
	)

	tween.tween_callback(func():
		Engine.time_scale = 1.0
		await get_tree().create_timer(1.0).timeout
		paused = false
		end_battle()
	)

func player_lose() -> void:
	transition_screen.black_screen()
	await get_tree().create_timer(1.0).timeout
	game_end.emit()
	queue_free()


func end_battle() -> void:
	paused = true
	game_ui.timer_panel.visible = false
	
	camera.switch_target(player, 50)
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		enemies_container,
		"position",
		rest_room_anchor.position,
		0.3
	)
	
	var current_val = retro_mat.get_shader_parameter("color_quant_steps")
	tween.tween_property(retro_mat, "shader_parameter/color_quant_steps", 10.0, 0.3).from(current_val)
	
	tween.tween_property(
			camera,
			"zoom",
			Vector2.ONE * 2.5,
			0.3
	)
	
	current_round = 0
	in_battle = false
	in_break = true
	battle_time_left = 1000
	battle_end.emit()
	advance_enemy()
	background.visible = false
	player.end_battle()
	enemy.end_battle()
	player.arm.movable_by_mouse = true
	print(current_level)
	rest_room.enter_rest_room(current_level)

func advance_enemy() -> void:
	player.opponent = null
	enemy.visible = false
	enemy.process_mode = Node.PROCESS_MODE_DISABLED
	current_level += 1

func next_round() -> void:
	paused = false
	
	in_break = false
	player.arm.movable_by_mouse = false
	battle_time_left = battle_duration
	camera.switch_target(arena_center, 50)
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	retro_screen.trans_to_combat()
	audio.muffle(false)

	tween.parallel().tween_property(
		enemies_container,
		"position",
		Vector2.ZERO,
		0.3
	)
	tween.parallel().tween_property(
		camera,
		"zoom",
		Vector2.ONE * 2,
		0.2
	)
	
	player.start_round()
	enemy.start_round()

func end_round() -> void:
	in_break = true
	current_round += 1
	battle_time_left = break_duration
	audio.muffle(true)
	
	if current_round >= max_round:
		end_battle()
	else:
		player.end_battle()
		enemy.end_battle()
		camera.switch_target(player, 50)
		retro_screen.trans_to_break()
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_IN_OUT)

		tween.tween_property(
			enemies_container,
			"position",
			corner.position,
			0.4
		)
		
		tween.tween_property(
			camera,
			"zoom",
			Vector2.ONE * 2.8,
			0.3
		)
	player.arm.movable_by_mouse = true
	
	if first_time:
		paused = true
		await get_tree().create_timer(0.5).timeout
		DialogueManager.say("IT'S NOT OVER YET BROTHER!")
		await get_tree().create_timer(0.25).timeout
		await DialogueManager.wait_for_dialogue_continue()
		DialogueManager.say("Lets fix that ugly ass face of yours now !")
		await get_tree().create_timer(0.25).timeout
		await DialogueManager.wait_for_dialogue_continue()
		DialogueManager.say("Just drag the broken parts to the right place.")
		await get_tree().create_timer(0.25).timeout
		await DialogueManager.wait_for_dialogue_continue()
		DialogueManager.say("The moron fighting against you, he has very short arms..")
		await get_tree().create_timer(0.25).timeout
		await DialogueManager.wait_for_dialogue_continue()
		DialogueManager.say("The motherfucker only have enough range to punch your mouth and your nose.")
		await get_tree().create_timer(0.25).timeout
		await DialogueManager.wait_for_dialogue_continue()
		DialogueManager.say("Be smart and use that to your advantage.")
		await get_tree().create_timer(0.25).timeout
		await DialogueManager.wait_for_dialogue_continue()
		DialogueManager.say("Block his attacks, and then punch his face loose.")
		await get_tree().create_timer(0.25).timeout
		await DialogueManager.wait_for_dialogue_continue()
		DialogueManager.say("Now you go, and beat the shit out of this baldhead.")
		await get_tree().create_timer(0.25).timeout
		await DialogueManager.wait_for_dialogue_continue()
		paused = false
	
	first_time = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		player_lose()
	if Input.is_action_just_pressed("ui_accept"):
		end_battle()
	if paused:
		return
	if battle_time_left <= 0:
		if in_break:
			next_round()
		else:
			end_round()
	elif in_battle:
		battle_time_left -= delta
		game_ui.set_round_ui(battle_time_left)

var distortion_tween: Tween
var barrel_distortion := 0.0

func _screen_shake(value: float, crit := false) -> void:
	print("f")
	camera.add_trauma(value / 5)

	var peak : float = clamp(value * 0.15, 0.05, 0.35)

	if distortion_tween and distortion_tween.is_running():
		distortion_tween.kill()

	barrel_distortion = peak
	retro_mat.set_shader_parameter("barrel_distortion", barrel_distortion)
	
	if crit:
		Engine.time_scale = 0.4

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_method(
		func(v):
			barrel_distortion = v
			retro_mat.set_shader_parameter("barrel_distortion", v),
		barrel_distortion,
		0.0,
		0.15 + randf_range(-0.05, 0.15)
	)
	
	tween.tween_method(
		func(v):
			barrel_distortion = v
			retro_mat.set_shader_parameter("barrel_distortion", v),
		barrel_distortion,
		0.5,
		0.3 + randf_range(-0.05, 0.15)
	)
	
	tween.tween_callback(func():
		Engine.time_scale = 1.0
	)
