class_name Arm extends Node2D

signal action_finished(blocking: bool)

@onready var skeleton: Skeleton2D = $Skeleton2D
@onready var fist_target: Marker2D = %FistTarget
@export var windup_distance := 18.0
@export var windup_strength := 1.0

var rest_position: Vector2
var windup_position: Vector2
var is_punching := false
var is_blocking := false
var interrupted := false

@export var arm_dir := 1

func _ready() -> void:
	rest_position = fist_target.global_position
	windup_position = rest_position

func rest_pos() -> void:
	if interrupted:
		return
	
	is_punching = false
	is_blocking = false
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		fist_target,
		"global_position",
		rest_position,
		0.25 + randf_range(-0.05,0.15)
	)

func update_windup(progress: float, attack_dir: Vector2) -> void:
	if is_punching:
		return

	var eased := ease(progress, 0.7)
	windup_position = rest_position - attack_dir * windup_distance * eased * windup_strength

	fist_target.global_position = fist_target.global_position.lerp(
		windup_position,
		0.15
	)

func block_success() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	var blocking_pos := fist_target.global_position
	var knock_back_pos := Vector2(randf_range(-10, 10), randf_range(20,25)) * arm_dir
	
	tween.tween_property(
		fist_target,
		"global_position",
		fist_target.global_position + knock_back_pos,
		0.2 + randf_range(-0.05,0.15)
	)
	
	
	tween.tween_property(
		fist_target,
		"global_position",
		blocking_pos,
		0.3 + randf_range(-0.05,0.15)
	)


func block(target_global_pos: Vector2) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		fist_target,
		"global_position",
		target_global_pos,
		0.2 + randf_range(-0.05,0.15)
	)

	tween.tween_callback(func():
		is_blocking = true
		emit_signal("action_finished", is_blocking)
	)

func punch(target_global_pos: Vector2, on_hit: Callable) -> void:
	if is_punching:
		return
	is_blocking = false
	is_punching = true

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	var wind_up_pos := Vector2(randf_range(1,2), randf_range(1,2))
	
	tween.tween_property(
		fist_target,
		"global_position",
		global_position + wind_up_pos,
		0.5 + randf_range(-0.2,0.2)
	)
	
	# Move fist to target
	tween.tween_property(
		fist_target,
		"global_position",
		target_global_pos,
		0.2 + randf_range(-0.05,0.15)
	)

	# Apply damage at peak
	tween.tween_callback(on_hit)

	# Return to rest
	tween.tween_property(
		fist_target,
		"global_position",
		rest_position,
		0.4
	)

	tween.tween_callback(func():
		is_punching = false
		emit_signal("action_finished", is_blocking)
	)

func interrupt(on_recover: Callable) -> void:
	interrupted = true
	is_punching = false
	is_blocking = false
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	var interrupted_pos := Vector2(randf_range(100,200), randf_range(1,2)) * arm_dir
	
	tween.tween_property(
		fist_target,
		"global_position",
		rest_position + interrupted_pos,
		0.3 + randf_range(-0.05,0.15)
	)

	tween.tween_callback(func():
		interrupted = false
		on_recover.call()
		rest_pos()
	)
