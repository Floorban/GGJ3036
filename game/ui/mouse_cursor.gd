extends Sprite2D

var hovering := false

@export var normal_texture: Texture2D
@export var attack_texture: Texture2D
@export var block_texture: Texture2D
@export var cross_texture: Texture2D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, get_global_mouse_position(), 16.5*delta)
	
	var target_rotation : float = -20.0 if Input.is_action_pressed("left_click") else 0.0
	rotation_degrees = lerp(rotation_degrees, target_rotation, 16.5*delta)
	
	var target_scale: Vector2 = Vector2(1.0,1.0) if Input.is_action_pressed("left_click") else Vector2(1.2,1.2)
	scale = lerp(scale, target_scale, 16.5*delta)

func choose_normal() -> void:
	texture = normal_texture
	hovering = false

func choose_attack() -> void:
	texture = attack_texture
	hovering = true

func choose_block() -> void:
	texture = block_texture
	hovering = true

func choose_unvalid() -> void:
	texture = cross_texture
	hovering = true
