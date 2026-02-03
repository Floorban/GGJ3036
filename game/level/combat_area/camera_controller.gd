class_name CameraController extends Camera2D

## cam shake
@export var decay : float = 0.8 
@export var max_offset : Vector2 = Vector2(100, 75) 
@export var max_roll : float = 0.1 
var trauma : float = 0.0 
var trauma_power : int = 2 

## cam follow
@export var follow_node : Node2D 
const MAX_DIST = 20
var target_distance = 0
var center_pos : Vector2

@onready var crosshair: Sprite2D = $Crosshair
var lock_target : Node2D

func _on_pause(pause: bool):
	#crosshair.global_position = follow_node.global_position
	crosshair.visible = !pause

func _ready() -> void:
	#Global.connect("game_pause", _on_pause)
	center_pos = position

func _process(delta : float) -> void:
	#if Global.paused: 
		#return
	_cam_follow(delta)
	_cam_pan(delta)
	if trauma: 
		trauma = max(trauma - decay * delta, 0) 
		_shake() 

func _cam_follow(delta: float):
	if follow_node: 
		center_pos = lerp(center_pos, follow_node.global_position, delta) 

func _cam_pan(delta: float):
	var direction = center_pos.direction_to(get_global_mouse_position())
	var target_pos = center_pos + direction * target_distance
	
	target_pos = target_pos.clamp(
		center_pos - Vector2(MAX_DIST, MAX_DIST),
		center_pos + Vector2(MAX_DIST, MAX_DIST)
	)
	global_position =  lerp(global_position, target_pos, delta)
	if lock_target == null:
		# must put it after update cam's pos to avoid jittering
		crosshair.position = get_local_mouse_position()
	else:
		crosshair.global_position = lock_target.global_position

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		target_distance = center_pos.distance_to(get_global_mouse_position())

func add_trauma(amount: float):
	trauma = min(trauma + amount, 1.0)

func _shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-10, 10)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)
