extends Node2D

signal battle_start
signal battle_end

@onready var background: Sprite2D = %Background
@onready var rest_room: RestRoom = $RestRoom
@onready var arena_center: Marker2D = %ArenaCenter
@onready var corner: Marker2D = %Corner
@onready var enemies_container: Node2D = $Enemies
var start_pos : Vector2

@onready var camera: CameraController = $Camera
@onready var game_ui: GameUI = %GameUI
@onready var retro_screen: RetroScreen = %RetroScreen
var retro_mat: ShaderMaterial
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

var enemies: Array[Enemy]
@onready var player: Player = %Player
var enemy: Enemy

func _ready() -> void:
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
	enemy = enemies[level - 1]
	enemy.visible = true
	battle_time_left = battle_duration
	player.opponent = enemy
	enemy.opponent = player
	enemy.init_character()
	enemy.die.connect(end_battle)
	if first_level:
		#current_round = 1
		player.init_character()
		player.hit.connect(_screen_shake)
		player.blocked.connect(_screen_shake)
		player.die.connect(end_battle)

func start_battle() -> void:
	in_break = false
	in_battle = true
	background.visible = true
	init_combat_arena(current_level)
	player.get_ready_to_battle()
	enemy.get_ready_to_battle()
	battle_start.emit()

func end_battle() -> void:
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
	rest_room.enter_rest_room()

func advance_enemy() -> void:
	player.opponent = null
	enemy.visible = false
	enemy.process_mode = Node.PROCESS_MODE_DISABLED
	current_level += 1

func next_round() -> void:
	in_break = false
	player.arm.movable_by_mouse = false
	battle_time_left = battle_duration
	camera.switch_target(arena_center, 50)
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	retro_screen.trans_to_combat()

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

func _process(delta: float) -> void:
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
	camera.add_trauma(value / 10)

	var peak : float = clamp(value * 0.15, 0.05, 0.35)

	if distortion_tween and distortion_tween.is_running():
		distortion_tween.kill()

	barrel_distortion = peak
	retro_mat.set_shader_parameter("barrel_distortion", barrel_distortion)
	
	if crit:
		Engine.time_scale = 0.4

	Engine.time_scale = 0.0
	for i in 8:
		await get_tree().physics_frame
	Engine.time_scale = 1.0
	
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
