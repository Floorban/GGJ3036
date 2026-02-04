extends Node2D

signal battle_start
signal battle_end

@onready var camera: CameraController = $Camera
@onready var game_ui: GameUI = %GameUI
@onready var retro_screen: ColorRect = %RetroScreen
var retro_mat: ShaderMaterial
@export var battle_duration := 90.0
var battle_time_left: float

# level 0 is tutorial VS bully
@export var current_level := 0
@export var current_round := 1

var enemies: Array[Enemy]
@export var player: Player
@export var enemy: Enemy

func _ready() -> void:
	enemies.clear()
	for e in $Enemies.get_children():
		if e is Enemy:
			enemies.append(e)
	retro_mat = retro_screen.material as ShaderMaterial
	init_combat_arena(current_level)

func init_combat_arena(level : int) -> void:
	enemy = enemies[level]
	enemy.visible = true
	battle_time_left = battle_duration
	player.opponent = enemy
	enemy.opponent = player
	player.init_character()
	enemy.init_character()
	player.hit.connect(_screen_shake)
	player.blocked.connect(_screen_shake)
	player.die.connect(end_battle)
	enemy.die.connect(end_battle)

func start_battle() -> void:
	player.get_ready_to_battle()
	enemy.get_ready_to_battle()
	battle_start.emit()

func end_battle() -> void:
	player.end_battle()
	enemy.end_battle()
	print("over")

func _process(delta: float) -> void:
	if battle_time_left <= 0:
		battle_time_left = 0
		battle_end.emit()
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
		1.0,
		0.3 + randf_range(-0.05, 0.15)
	)
	
	tween.tween_callback(func():
		Engine.time_scale = 1.0
	)
