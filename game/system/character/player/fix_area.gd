class_name FixArea extends Area2D

@export var is_trach_bin := false

@onready var rest_room: RestRoom = get_tree().get_first_node_in_group("rest_room")
@onready var player: Player = get_tree().get_first_node_in_group("player")
@export var anatomy_type: Anatomy.AnatomyType
var last_anatomy: Anatomy
@export var my_anatomy: Anatomy
@onready var sprite: Sprite2D = $Sprite
var sprite_og_color: Color
var is_occupied := false
var is_hovering := false

var sfx_trash: String = "event:/SFX/Surgery/Trash"

func _ready() -> void:
	is_occupied = true
	reset_sprite()
	#if my_anatomy: anatomy_type = my_anatomy.anatomy_type
	#mouse_entered.connect(_on_input_event)
	#mouse_exited.connect(_unhover_part)
	#input_event.connect(_on_input_event)
	if my_anatomy and not my_anatomy.anatomy_fucked.is_connected(lose_anatomy):
		last_anatomy = my_anatomy
		my_anatomy.anatomy_fucked.connect(lose_anatomy)
	#player.start.connect(reset_sprite)

func lose_anatomy() -> void:
	if my_anatomy == null:
		is_occupied = false
		return
	if my_anatomy in player.anatomy_parts:
		my_anatomy.body_owner = null
		if player.rest_mode:
			player.anatomy_parts.erase(my_anatomy)
			my_anatomy.reparent(rest_room.background)
			my_anatomy.z_index = 500
	sprite.visible = true
	sprite.rotate(randf_range(-0.2,0.2))
	if my_anatomy.anatomy_fucked.is_connected(lose_anatomy):
		my_anatomy.anatomy_fucked.disconnect(lose_anatomy)
	my_anatomy = null
	is_occupied = false

func reparent_anatomy(target: Node2D, new_parent: Node2D) -> void:
	if target.get_parent() != new_parent:
		target.reparent(new_parent)

@export var is_left_ear := false

func receive_anatomy(anatomy: Anatomy) -> void:
	if is_trach_bin:
		anatomy.part_dead()
		anatomy.queue_free()
		audio.play(self, sfx_trash)
		if anatomy.i_blood != null: audio.clear_instance([anatomy.i_blood])
		return
	if is_occupied or anatomy.anatomy_type != anatomy_type or anatomy.state == anatomy.PartState.DESTROYED or anatomy.current_hp <= 0:
		return

	Tutorial.on_first_surgery()
	
	is_occupied =  true
	rest_room.attaching = true
	#sprite.visible = false
	sprite.modulate = Color.WEB_GRAY
	sprite_og_color = sprite.modulate
	reparent_anatomy(anatomy, player.features)

	if last_anatomy:
		if last_anatomy in player.anatomy_parts:
			if player.rest_mode:
				player.anatomy_parts.erase(last_anatomy)
				last_anatomy.reparent(rest_room.background)
				last_anatomy.z_index = 500
		last_anatomy.state = Anatomy.PartState.OutOfBody
		last_anatomy.body_owner = null
		last_anatomy = my_anatomy
		rest_room.attached_index += 1
	
	player.anatomy_parts.append(anatomy)
	audio.play(rest_room, rest_room.sfx_attach, global_transform, "Juice", rest_room.attached_index)
	anatomy.body_owner = player
	anatomy.position = position
	anatomy.rotation = rotation
	anatomy.og_pos = global_position
	my_anatomy = anatomy
	if not my_anatomy.anatomy_fucked.is_connected(lose_anatomy): my_anatomy.anatomy_fucked.connect(lose_anatomy)
	player.arm.drop_obj()
	anatomy.recover_part()
	#PopupPrompt.display_prompt("Fixed", -1 ,sprite.global_position, 0.2, 0.45)
	if anatomy.anatomy_type == Anatomy.AnatomyType.Ear and is_left_ear:
		anatomy.sprite.flip_h = false
	else:
		anatomy.sprite.flip_h = true
	rest_room.attaching = false

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
			#get_viewport().set_input_as_handled()

func highlight_zone() -> void:
	if is_hovering or player.can_control or player.arm.dragging_obj == null:
		return
	sprite.modulate *= 2.0
	is_hovering = true

func unhighlight_zone() -> void:
	sprite.modulate = sprite_og_color
	is_hovering = false
