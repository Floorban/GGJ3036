class_name Character extends Node2D

signal hit(damage: float)
signal blocked(blocked_damage: float)

signal die()

var can_control := true
var is_dead := false
var max_health : float
var health : float

@export var critical_chance := 0.2
@export var punch_strength := 0.1

@export var top_down_dir := 1

var opponent: Character
@onready var combat_component: CombatComponent = %CombatComponent
@export var attack_damage: float = 1.0
@export var action_cooldown: float = 2.0

@onready var features: Node2D = %Features

@export var anatomy_parts: Array[Anatomy]
@export var opponent_anatomy: Array[Anatomy]

@export var arm: Arm
var can_action := false
var blocking_part: Anatomy
var targeting_part: Anatomy

@onready var face: Sprite2D = $Face
@onready var shoulder: Sprite2D = $Shoulder

func init_character() -> void:
	_init_anatomy_parts()
	_init_combat_component()
	get_anatomy_references()

func get_anatomy_references() -> void:
	for anatomy : Anatomy in get_tree().get_nodes_in_group("anatomy"):
		if anatomy.visible and anatomy.body_owner != self:
			opponent_anatomy.append(anatomy)

func _init_combat_component() -> void:
	combat_component.combat_ready.connect(_on_action_ready)
	arm.action_finished.connect(func(blocking: bool): _on_action_finished(blocking))
	combat_component.base_damage = attack_damage
	combat_component.reset_attack_timer(action_cooldown)

func _init_anatomy_parts() -> void:
	for anatomy in features.get_children():
		if anatomy.visible:
			anatomy_parts.append(anatomy)
	for part in anatomy_parts:
		part.init_part(self)
		part.anatomy_hit.connect(
		func(dmg): resolve_hit(part, dmg, opponent)
		)
		max_health += part.max_hp

func get_ready_to_battle() -> void:
	combat_component.start()
	is_dead = false
	can_control = true
	for part in anatomy_parts:
		part.recover_part()
	health = max_health

func end_battle() -> void:
	combat_component.stop()
	can_control = false
	arm.set_cd_bar(0,0)

func _process(_delta: float) -> void:
	if is_dead or not can_control:
		return
	arm.set_cd_bar(action_cooldown - combat_component.combat_timer.time_left, action_cooldown)

func resolve_hit(target: Anatomy, damage: float, attacker: Character) -> void:
	arm.sprite_fist.modulate = Color.DIM_GRAY
	
	if blocking_part == target and can_action:
		_on_successful_block(attacker)
		return

	# Failed block or no block
	if arm.is_blocking and blocking_part:
		_on_block_finished()
	target.set_hp(damage)
	health -= damage
	var dead_anatomy := 0
	for a in anatomy_parts:
		if a.is_part_dead(): dead_anatomy += 1
	if health <= 0 or dead_anatomy >= anatomy_parts.size():
		die.emit()
	hit.emit(damage * 1.5)
	get_hit_visual_feedback(damage / 15)

var face_tween : Tween
var face_og_pos : Vector2
var face_og_rot : float
var face_current_rot: float

func rand_outside_range(min_abs: float, max_abs: float) -> float:
	var sign : int = [-1, 1].pick_random()
	return sign * randf_range(min_abs, max_abs)

func get_hit_visual_feedback(damage_scale: float) -> void:
	# Kill previous hit reactions
	if face_tween:
		face_tween.kill()

	face_og_pos = face.global_position
	face_og_rot = face.global_rotation

	var pos_offset := Vector2(
		rand_outside_range(-100, -250),
		randf_range(-20, -100) * top_down_dir
	) * damage_scale

	var rot_offset := rand_outside_range(3, 5) * damage_scale

	var hit_time := damage_scale + randf_range(-0.15, 0.05)

	face_tween = create_tween()
	face_tween.set_trans(Tween.TRANS_QUAD)
	face_tween.set_ease(Tween.EASE_OUT)

	face_tween.parallel().tween_property(
		face,
		"global_position",
		face_og_pos + pos_offset,
		hit_time
	)

	face_tween.parallel().tween_property(
		face,
		"global_rotation",
		face_og_rot + rot_offset,
		hit_time
	)
	
	face_current_rot = face.global_rotation

	face_tween.parallel().tween_method(
		func(value):
			face.rotation = value,
		face_current_rot,
		face_current_rot + rot_offset,
		hit_time
	)

	face_tween.tween_callback(face_return)

func face_return() -> void:
	var return_time := 0.15 + randf_range(-0.05, 0.12)

	face_tween = create_tween()
	face_tween.set_trans(Tween.TRANS_QUAD)
	face_tween.set_ease(Tween.EASE_OUT)

	face_tween.parallel().tween_property(
		face,
		"global_position",
		face_og_pos,
		return_time
	)

	face_tween.parallel().tween_property(
		face,
		"rotation",
		face_og_rot,
		return_time
	)

func _on_successful_block(attacker: Character) -> void:
	blocked.emit(1.0)
	can_action = false
	attacker.arm.interrupt(func(): 
		attacker.can_action = false
	)
	arm.block_success()
	combat_component.reset_attack_timer(action_cooldown)
	combat_component.start()
	
	if blocking_part:
		blocking_part._highlight_target(true)

func _perform_attack(target: Anatomy) -> void:
	can_action = false
	arm._on_arm_charge_finished(punch_strength * 3)
	await get_tree().create_timer(punch_strength * 2).timeout
	if target:
		if blocking_part:
			blocking_part.is_blocking = false
		arm.punch(
			punch_strength,
			target.global_position,
			func():
				var crit := randf() < critical_chance
				var dmg := attack_damage
				if crit: dmg *= 3
				target.anatomy_hit.emit(dmg)
				hit.emit(dmg, crit)
		)

func _perform_block(target: Anatomy) -> void:
	if can_action:
		arm._on_arm_charge_finished(punch_strength * 3)
	blocking_part = target
	target.is_blocking = true
	target._highlight_target(true)
	arm.block(target.global_position)

func _on_action_ready() -> void:
	can_action = true
	if blocking_part:
		arm._on_arm_charge_finished(punch_strength * 3)

func _on_action_finished(blocking: bool) -> void:
	if not blocking:
		_on_attack_finished()

func _on_attack_finished() -> void:
	if targeting_part:
		targeting_part.is_targeted = false
		targeting_part._unhighlight_target()
	combat_component.start()
	arm.sprite_fist.modulate = Color.DIM_GRAY

func _on_block_finished() -> void:
	arm.sprite_fist.modulate = Color.DIM_GRAY
	blocking_part.is_blocking = false
	blocking_part = null

func choose_target() -> Anatomy:
	if opponent == null:
		targeting_part = null
		return null

	var valid_targets := opponent.anatomy_parts.filter(
		func(part): return part.state != Anatomy.PartState.DESTROYED)

	if valid_targets.is_empty():
		targeting_part = null
		return null
		
	var new_target: Anatomy = valid_targets.pick_random()
	targeting_part = new_target
	targeting_part.is_targeted = true
	targeting_part._highlight_target()
	return new_target
