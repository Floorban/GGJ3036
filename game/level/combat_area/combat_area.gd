extends Node2D

signal battle_start
signal battle_end

@onready var camera: CameraController = $Camera
@onready var game_ui: GameUI = %GameUI
@onready var retro_screen: ColorRect = %RetroScreen
var retro_mat: ShaderMaterial
@export var battle_duration := 60.0
var battle_time_left: float
@export var battle_ongoing : bool = false
	#set(value):
		#battle_ongoing = value
		#if battle_ongoing:
			#start_battle()

@export var player: Player
@export var enemy: Enemy

#AUDIO
@export var sfx_hit: String

func _ready() -> void:
	retro_mat = retro_screen.material as ShaderMaterial
	init_combat_arena()
	if battle_ongoing:
		start_battle()

func init_combat_arena() -> void:
	enemy.visible = true
	battle_time_left = battle_duration
	player.opponent = enemy
	enemy.opponent = player
	player.init_character()
	enemy.init_character()
	player.hit.connect(_screen_shake)
	player.blocked.connect(_screen_shake)

func start_battle() -> void:
	player.get_ready_to_battle()
	enemy.get_ready_to_battle()
	battle_start.emit()

func end_battle() -> void:
	pass

func _process(delta: float) -> void:
	if battle_time_left <= 0:
		battle_time_left = 0
		battle_ongoing = false
		battle_end.emit()
	if battle_ongoing:
		battle_time_left -= delta
		game_ui.set_round_ui(battle_time_left)

var distortion_tween: Tween
var barrel_distortion := 0.0

func _screen_shake(value: float, crit := false) -> void:
	camera.add_trauma(value / 3)

	var peak : float = clamp(value * 0.15, 0.05, 0.35)

	if distortion_tween and distortion_tween.is_running():
		distortion_tween.kill()

	barrel_distortion = peak
	retro_mat.set_shader_parameter("barrel_distortion", barrel_distortion)
	
	if crit:
		Engine.time_scale = 0.4
		audio.play(sfx_hit, global_transform, "Impact", "Fatal")
	
	else:
			audio.play(sfx_hit, global_transform, "Impact", "Normal")
	
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
