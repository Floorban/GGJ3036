extends Node2D

signal battle_start
signal battle_end

@onready var arena_center: Marker2D = %ArenaCenter
@onready var corner: Marker2D = %Corner
var start_pos : Vector2

@onready var camera: CameraController = $Camera
@onready var game_ui: GameUI = %GameUI
@onready var retro_screen: ColorRect = %RetroScreen
var retro_mat: ShaderMaterial
@export var battle_duration := 40.0
var break_duration := 15.0
var in_break := false
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
	start_pos = player.position
	enemies.clear()
	for e in $Enemies.get_children():
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
	init_combat_arena(current_level)
	player.get_ready_to_battle()
	enemy.get_ready_to_battle()
	battle_start.emit()

func end_battle() -> void:
	in_break = true
	battle_time_left = 1000
	battle_end.emit()
	advance_enemy()

func advance_enemy() -> void:
	player.opponent = null
	enemy.visible = false
	enemy.process_mode = Node.PROCESS_MODE_DISABLED
	current_level += 1

func next_round() -> void:
	in_break = false
	player.arm.movable_by_mouse = false
	battle_time_left = battle_duration
	player.global_position = start_pos
	camera.switch_target(arena_center, 100.0)
	player.start_round()
	enemy.start_round()

func end_round() -> void:
	in_break = true
	current_round += 1
	player.end_battle()
	enemy.end_battle()
	battle_time_left = break_duration
	if current_round >= max_round:
		end_battle()
	else:
		camera.switch_target(corner, 100.0)
		player.global_position = corner.global_position
	player.arm.movable_by_mouse = true

func _process(delta: float) -> void:
	if battle_time_left <= 0:
		if in_break:
			next_round()
		else:
			end_round()
	else:
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
