extends CanvasLayer

@onready var mouse_cursor: Sprite2D = $MouseCursor

var hovering := false

@export var normal_texture: Texture2D
@export var attack_texture: Texture2D
@export var block_texture: Texture2D
@export var cross_texture: Texture2D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _physics_process(delta: float) -> void:
	mouse_cursor.global_position = lerp(mouse_cursor.global_position, get_viewport().get_mouse_position(), 20 * delta)
	
	var target_rotation : float = -20.0 if Input.is_action_pressed("left_click") else 0.0
	mouse_cursor.rotation_degrees = lerp(mouse_cursor.rotation_degrees, target_rotation, 20 * delta)
	
	var target_scale: Vector2 = Vector2(1.5,1.5) if Input.is_action_pressed("left_click") else Vector2(1.8,1.8)
	mouse_cursor.scale = lerp(mouse_cursor.scale, target_scale, 16.5*delta)

func choose_normal() -> void:
	mouse_cursor.texture = normal_texture
	hovering = false

func choose_attack() -> void:
	mouse_cursor.texture = attack_texture
	hovering = true

func choose_block() -> void:
	mouse_cursor.texture = block_texture
	hovering = true

func choose_unvalid() -> void:
	mouse_cursor.texture = cross_texture
	hovering = true
