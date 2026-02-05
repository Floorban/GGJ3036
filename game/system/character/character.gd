class_name Character extends Node2D

signal hit(damage: float)
signal blocked(blocked_damage: float)
signal start()
signal die()

var rest_mode := false

var can_control := true
var is_dead := false
var is_stuned := false
var max_health : float
@export var health : float

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

#AUDIO
var sfx_block: String = "event:/SFX/Combat/Block"
var sfx_crit: String = "event:/SFX/Combat/Crit"
var sfx_hit: String = "event:/SFX/Combat/Hit"

func init_character() -> void:
	_init_anatomy_parts()
	_init_combat_component()
	get_anatomy_references()

func get_anatomy_references() -> void:
	opponent_anatomy.clear()
	for anatomy : Anatomy in get_tree().get_nodes_in_group("anatomy"):
		if anatomy.visible and anatomy.body_owner != self and anatomy.state != Anatomy.PartState.OutOfBody:
			opponent_anatomy.append(anatomy)

func _init_combat_component() -> void:
	if not combat_component.combat_ready.is_connected(_on_action_ready):
		combat_component.combat_ready.connect(_on_action_ready)
	arm.action_finished.connect(func(blocking: bool): _on_action_finished(blocking))
	combat_component.base_damage = attack_damage
	combat_component.reset_attack_timer(action_cooldown)

func _init_anatomy_parts() -> void:
	anatomy_parts.clear()
	for anatomy: Anatomy in features.get_children():
		if anatomy.visible and anatomy.state != Anatomy.PartState.OutOfBody:
			anatomy_parts.append(anatomy)
	for part in anatomy_parts:
		part.init_part(self)
		part.anatomy_hit.connect(
		func(dmg): resolve_hit(part, dmg, opponent)
		)
		max_health += part.max_hp
	start.emit()

func get_ready_to_battle() -> void:
	arm.movable_by_mouse = false
	arm.rest_pos()
	start_round()
	is_dead = false
	for part in anatomy_parts:
		part.recover_part()

func end_battle() -> void:
	for part in anatomy_parts:
		part.is_blocking = false
		part.is_targeted = false
		part._unhighlight_target()
	combat_component.stop()
	can_action = false
	can_control = false
	arm.set_cd_bar(0,1)
	arm.drop_obj()
	arm.toggle_arm(true)

func start_round() -> void:
	combat_component.start()
	can_control = true
	if targeting_part:
		targeting_part.is_targeted = false
		targeting_part._unhighlight_target()

func _process(_delta: float) -> void:
	if is_dead or not can_control or is_stuned:
		return
	arm.set_cd_bar(action_cooldown - combat_component.combat_timer.time_left, action_cooldown)

func resolve_hit(target: Anatomy, damage: float, attacker: Character) -> void:
	if not can_control:
		target.is_targeted = false
		target._unhighlight_target()
		return
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
		if a and a.is_part_dead(): dead_anatomy += 1
	if health <= 0 or dead_anatomy >= anatomy_parts.size():
		die.emit()
	hit.emit(damage * 1.5)
	get_hit_visual_feedback(damage / 10)

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

	var hit_time := 0.05 + damage_scale + randf_range(-0.15, 0.05)

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

	face_tween.tween_callback(func():
		face_return(0.2 * damage_scale)
		)

func face_return(duration: float) -> void:
	var return_time := duration + randf_range(0.05, 0.15)

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

func on_interrupted() -> void:
	can_action = false
	is_stuned = true
	combat_component.stop()
	arm.toggle_arm(false)

func recover_from_interrupt() -> void:
	await get_tree().create_timer(action_cooldown / 2).timeout
	arm.toggle_arm(true)
	combat_component.start()
	is_stuned = false

func _on_successful_block(attacker: Character) -> void:
	PopupPrompt.display_prompt("BLCOKED !!", -1 ,arm.sprite_fist.global_position, 1.5, 0.5)
	audio.play(sfx_block, global_transform, "Intensity", 0.75)
	blocked.emit(1.0)
	can_action = false
	attacker.on_interrupted()
	attacker.arm.interrupt(func(): 
		attacker.recover_from_interrupt()
	)
	arm.block_success()
	
	combat_component.reset_attack_timer(action_cooldown)
	combat_component.start()
	
	if blocking_part:
		blocking_part.is_targeted = false
		blocking_part._unhighlight_target()

func _perform_attack(target: Anatomy) -> void:
	#if not can_control:
		#target.is_targeted = false
		#target._unhighlight_target()
	#return
	can_action = false
	arm._on_arm_charge_finished(punch_strength * 3)
	await get_tree().create_timer(punch_strength * 2).timeout
	if target:
		if blocking_part:
			blocking_part.is_blocking = false
			blocking_part.is_targeted = false
			blocking_part._unhighlight_target()
		arm.punch(
			punch_strength,
			target.global_position,
			func():
				if not can_control:
					target.is_targeted = false
					target._unhighlight_target()
					return
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
	arm.block(target.global_position)

func _on_action_ready() -> void:
	if not can_control:
		return
	can_action = true
	if blocking_part:
		arm._on_arm_charge_finished(punch_strength * 3)

func _on_action_finished(blocking: bool) -> void:
	if not blocking and can_control:
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
		func(part): return part and part.state != Anatomy.PartState.DESTROYED)

	if valid_targets.is_empty():
		targeting_part = null
		return null
		
	var new_target: Anatomy = valid_targets.pick_random()
	targeting_part = new_target
	if can_control:
		targeting_part.is_targeted = true
		#targeting_part._highlight_target()
	return new_target

func reveal_target_with_delay(target: Anatomy) -> void:
	if not target or not can_control:
		return

	var delay := randf_range(0.0, 0.5) + action_cooldown * 0.5
	await get_tree().create_timer(delay).timeout

	if target != targeting_part or not can_control:
		return
	if not rest_mode:
		target.is_targeted = true
		target._highlight_target()
