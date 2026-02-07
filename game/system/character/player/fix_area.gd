class_name FixArea extends Area2D

@onready var rest_room: RestRoom = get_tree().get_first_node_in_group("rest_room")
@onready var player: Player = get_tree().get_first_node_in_group("player")
@export var anatomy_type: Anatomy.AnatomyType
var last_anatomy: Anatomy
@export var my_anatomy: Anatomy
@onready var sprite: Sprite2D = $Sprite
var sprite_og_color: Color
var is_occupied := false
var is_hovering := false

func _ready() -> void:
	reset_sprite()
	#if my_anatomy: anatomy_type = my_anatomy.anatomy_type
	#mouse_entered.connect(_hover_over_part)
	#mouse_exited.connect(_unhover_part)
	input_event.connect(_on_input_event)
	if my_anatomy and not my_anatomy.anatomy_fucked.is_connected(lose_anatomy):
		last_anatomy = my_anatomy
		my_anatomy.anatomy_fucked.connect(lose_anatomy)
	player.start.connect(reset_sprite)

func lose_anatomy() -> void:
	sprite.visible = true
	sprite.rotate(randf_range(-0.5,0.5))
	my_anatomy = null
	is_occupied = false

func reparent_anatomy(target: Node2D, new_parent: Node2D) -> void:
	if target.get_parent() != new_parent:
		target.reparent(new_parent)

func receive_anatomy(anatomy: Anatomy) -> void:
	if is_occupied or anatomy.anatomy_type != anatomy_type or anatomy.state == anatomy.PartState.DESTROYED or anatomy.current_hp <= 0:
		return
	#sprite.visible = false
	sprite.modulate = Color.WEB_GRAY
	sprite_og_color = sprite.modulate
	reparent_anatomy(anatomy, player.features)
	if last_anatomy:
		last_anatomy.state = Anatomy.PartState.OutOfBody
		last_anatomy.body_owner = null
		last_anatomy = my_anatomy
	anatomy.body_owner = player
	anatomy.position = position
	anatomy.rotation = rotation
	anatomy.og_pos = global_position
	my_anatomy = anatomy
	if not my_anatomy.anatomy_fucked.is_connected(lose_anatomy): my_anatomy.anatomy_fucked.connect(lose_anatomy)
	is_occupied =  true
	player.arm.drop_obj()
	anatomy.recover_part()

func reset_sprite() -> void:
	sprite.modulate = Color.WHITE_SMOKE
	sprite_og_color = sprite.modulate
	sprite.visible = false

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if player.arm.dragging_obj == null:
		return
	if event is InputEventMouseButton and event.is_released():
		if event.button_index == MOUSE_BUTTON_LEFT:
			var target : Anatomy = player.arm.dragging_obj 
			player.arm.z_index = 2
			receive_anatomy(target)
			get_viewport().set_input_as_handled()

func highlight_zone() -> void:
	if is_hovering or is_occupied or player.can_control or player.arm.dragging_obj == null:
		return
	sprite.modulate *= 2.0
	is_hovering = true

func unhighlight_zone() -> void:
	sprite.modulate = sprite_og_color
	is_hovering = false
