class_name Arm extends Node2D

signal action_finished(blocking: bool)

@export var movable_by_mouse := false
@export var dragging_obj: Node2D

var arm_og_color: Color
@onready var sprite_arm_up: Sprite2D = %SpriteArmUp
@onready var sprite_arm_low: Sprite2D = %SpriteArmLow
@onready var cd_bar_1: TextureProgressBar = %CDBar1
@onready var cd_bar_2: TextureProgressBar = %CDBar2
@onready var sprite_fist: Sprite2D = %SpriteFist

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
	arm_og_color = sprite_arm_up.modulate
	rest_position = fist_target.global_position
	windup_position = rest_position
	sprite_fist.modulate = Color.DIM_GRAY

func _process(_delta: float) -> void:
	if not movable_by_mouse:
		return
	
	fist_target.global_position = get_global_mouse_position()
	if dragging_obj:
		dragging_obj.global_position = fist_target.global_position

func pickup_obj(new_obj: Node2D) -> void:
	var old_obj = dragging_obj
	if dragging_obj: 
		drop_obj()

	dragging_obj = new_obj
	if dragging_obj is Anatomy: 
		if not dragging_obj.is_being_dragged:
			dragging_obj.pickup_part()
	if old_obj: old_obj.is_being_dragged = false


func drop_obj() -> void:
	if dragging_obj:
		if dragging_obj is Anatomy:
			dragging_obj.drop_part()
		dragging_obj = null

func toggle_arm(enabled: bool) -> void:
	if enabled:
		sprite_arm_up.modulate = arm_og_color
		sprite_arm_low.modulate = arm_og_color
		sprite_fist.modulate = arm_og_color
	else:
		set_cd_bar(0,1)
		sprite_arm_up.modulate = Color.DARK_SLATE_GRAY
		sprite_arm_low.modulate = Color.DARK_SLATE_GRAY
		sprite_fist.modulate = Color.DARK_SLATE_GRAY

func set_cd_bar(current: float, max_value: float) -> void:
	var half = max_value / 2
	if cd_bar_1.max_value != half: cd_bar_1.max_value = half
	if cd_bar_2.max_value != half: cd_bar_2.max_value = half
	
	current = clamp(current, 0.0, max_value)
	if current <= half:
		cd_bar_1.value = current
		cd_bar_2.value = 0
	else:
		cd_bar_1.value = half
		cd_bar_2.value = current - half

func _on_arm_charge_finished(scale_speed: float) -> void:
	sprite_fist.modulate = Color.WHITE * 2.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		sprite_fist,
		"scale",
		sprite_fist.scale * 1.5,
		scale_speed
	)
	
	tween.tween_property(
		sprite_fist,
		"scale",
		Vector2.ONE,
		scale_speed
	)

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

func punch(punch_speed: float, target_global_pos: Vector2, on_hit: Callable) -> void:
	if is_punching:
		return
	is_blocking = false
	is_punching = true

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	var wind_up_pos := rest_position - arm_dir * windup_distance * windup_strength * Vector2(randf_range(1,2), randf_range(1,2))
	
	tween.tween_property(
		fist_target,
		"global_position",
		global_position + wind_up_pos,
		punch_speed + 0.5 + randf_range(-0.2,0.2)
	)
	
	# Move fist to target
	tween.tween_property(
		fist_target,
		"global_position",
		target_global_pos,
		punch_speed + randf_range(0,0.05)
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
	
	var interrupted_pos := Vector2(randf_range(-50,-200), randf_range(-50,-200)) * arm_dir
	
	tween.tween_property(
		fist_target,
		"global_position",
		rest_position + interrupted_pos,
		0.4 + randf_range(0.05,0.15)
	)

	tween.tween_callback(func():
		interrupted = false
		on_recover.call()
		#rest_pos()
	)
