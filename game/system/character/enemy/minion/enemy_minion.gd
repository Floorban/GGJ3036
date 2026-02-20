class_name EnemyMinion extends Enemy

@export var minion_data : MinionData
@onready var arm_origin: Marker2D = %ArmOrigin

var face_base : Face
@onready var eye_l: Anatomy = %EyeL
@onready var eye_r: Anatomy = %EyeR
@onready var ear_l: Anatomy = %EarL
@onready var ear_r: Anatomy = %EarR
@onready var nose: Anatomy = %Nose
@onready var mouth: Anatomy = %Mouth

func init_character() -> void:
	_init_anatomy_parts()
	_init_combat_component()
	get_anatomy_references()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_randomize_minion()


func _init_anatomy_parts() -> void:
	super._init_anatomy_parts()
	set_up_minion()


func set_up_minion() -> void:
	if minion_data == null:
		return
	var new_arm = minion_data.arm_scene.instantiate()
	arm_origin.add_child(new_arm)
	arm = new_arm as Arm
	arm.position = Vector2.ZERO
	arm.fist_target.global_position = minion_data.arm_gesture
	arm.rest_position = arm.fist_target.global_position
	
	sfx_die = minion_data.sfx_die
	sfx_entry = minion_data.sfx_entry
	sfx_hurt = minion_data.sfx_hurt
	
	base_cooldown = minion_data.base_cooldown
	base_damage = minion_data.base_damage
	base_speed = minion_data.base_speed
	base_crit_chance = minion_data.base_crit_chance
	base_crit_damage = minion_data.base_stun_strength
	base_stun_resist = minion_data.base_stun_resist
	switch_chance = minion_data.switch_chance
	min_switch_time = minion_data.min_switch_time
	_randomize_minion()

func _randomize_minion() -> void:
	if face_base:
		face_base.queue_free()
		face_base = null
	if minion_data == null:
		return
	max_health = 0
	
	var chosen_face = minion_data.face_variants.pick_random().instantiate() as Face
	if chosen_face:
		face.add_child(chosen_face)
		face_base = chosen_face
		face.texture = face_base.face_sprite.texture
		eye_l.global_transform = face_base.eye_marker_l.global_transform
		eye_r.global_transform = face_base.eye_marker_r.global_transform
		ear_l.global_transform = face_base.ear_marker_l.global_transform
		ear_r.global_transform = face_base.ear_marker_r.global_transform
		nose.global_transform = face_base.nose_marker.global_transform
		mouth.global_transform = face_base.mouth_marker.global_transform
	face.scale = Vector2(0.55, 0.55) * randf_range(0.9, 1.1)
	face.rotation_degrees = randf_range(-5,5)
	_random_offset_to_parts([eye_l, eye_r, ear_l, ear_r, nose, mouth])
	
	var chosen_ear = minion_data.ear_variants.pick_random()
	var chosen_eye = minion_data.eye_variants.pick_random()
	var chosen_arm = minion_data.mouth_variants.pick_random()
	var chosen_leg = minion_data.nose_variants.pick_random()
	_assign_part(chosen_ear)
	_assign_part(chosen_eye)
	_assign_part(chosen_arm)
	_assign_part(chosen_leg)
	# max hp is assigned here after parts are assigned
	rebuild_stats()


func _random_offset_to_parts(parts: Array[Anatomy]) -> void:
	for part in parts:
		part.position += Vector2(randf_range(-3,3), randf_range(-3,3))
		part.rotation_degrees += randf_range(-8,8)
		part.scale *= randf_range(1.3, 1.5)

func _assign_part(chosen_part: AnatomyData) -> void:
	if chosen_part == null:
		return
	for part in anatomy_parts:
		if part.anatomy_type == chosen_part.get_anatomy_type():
			part.apply_data(chosen_part)
			max_health += part.max_hp

func character_die() -> void:
	super.character_die()
	#arm.queue_free()
