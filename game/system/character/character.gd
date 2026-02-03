class_name Character extends Node2D

var opponent: Character
@onready var combat_component: CombatComponent = %CombatComponent
@export var attack_damage: float = 1.0
@export var action_cooldown: float = 2.0

var anatomy_parts: Array[Anatomy]
@onready var eye_1: Anatomy = %EyeL
@onready var eye_2: Anatomy = %EyeR
@onready var ear_1: Anatomy = %EarL
@onready var ear_2: Anatomy = %EarR
@onready var nose: Anatomy = %Nose
@onready var mouth: Anatomy = %Mouth
var opponent_anatomy: Array[Anatomy]

@export var arm: Arm
var can_action := false
var blocking_part: Anatomy

func init_character() -> void:
	_init_anatomy_parts()
	_init_combat_component()
	get_anatomy_references()

func get_anatomy_references() -> void:
	for anatomy in get_tree().get_nodes_in_group("anatomy"):
		if anatomy.get_parent() != self:
			opponent_anatomy.append(anatomy)

func _init_combat_component() -> void:
	combat_component.combat_ready.connect(_on_action_ready)
	arm.action_finished.connect(func(blocking: bool): _on_action_finished(blocking))
	combat_component.base_damage = attack_damage
	combat_component.reset_attack_timer(action_cooldown)

func _init_anatomy_parts() -> void:
	anatomy_parts.append(eye_1)
	anatomy_parts.append(eye_2)
	anatomy_parts.append(ear_1)
	anatomy_parts.append(ear_2)
	anatomy_parts.append(nose)
	anatomy_parts.append(mouth)
	for part in anatomy_parts:
		part.init_part()
		part.anatomy_hit.connect(
		func(dmg): resolve_hit(part, dmg, opponent)
		)

func get_ready_to_battle() -> void:
	combat_component.combat_timer.start()

func _process(delta: float) -> void:
	arm.set_cd_bar(action_cooldown - combat_component.combat_timer.time_left, action_cooldown)

func resolve_hit(target: Anatomy, damage: float, attacker: Character) -> void:
	if blocking_part == target and can_action:
		_on_successful_block(attacker)
		return

	# Failed block or no block
	if arm.is_blocking and blocking_part:
		_on_block_finished()
	target.set_hp(damage)

func _on_successful_block(attacker: Character) -> void:
	can_action = false
	attacker.arm.interrupt(func(): attacker.can_action = false)
	arm.block_success()
	combat_component.reset_attack_timer(action_cooldown)
	combat_component.combat_timer.start()
	#attacker.combat_component.combat_timer.start()
	
	if blocking_part:
		blocking_part._highlight_target(true)

func _perform_attack(target: Anatomy) -> void:
	can_action = false
	arm._on_arm_charge_finished()
	await get_tree().create_timer(0.4).timeout
	if target:
		if blocking_part:
			blocking_part.is_blocking = false
		arm.punch(
			target.global_position,
			func(): target.anatomy_hit.emit(attack_damage))

func _perform_block(target: Anatomy) -> void:
	blocking_part = target
	target.is_blocking = true
	target._highlight_target(true)
	arm.block(target.global_position)

func _on_action_ready() -> void:
	can_action = true

func _on_action_finished(blocking: bool) -> void:
	if not blocking:
		_on_attack_finished()

func _on_attack_finished() -> void:
	combat_component.combat_timer.start()
	arm.sprite_fist.modulate = Color.DIM_GRAY

func _on_block_finished() -> void:
	blocking_part.is_blocking = false
	blocking_part = null

func choose_target() -> Anatomy:
	if opponent == null:
		return null

	var valid_targets := opponent.anatomy_parts.filter(
		func(part): return part.state != Anatomy.PartState.DESTROYED)

	if valid_targets.is_empty():
		return null
		
	var new_target: Anatomy = valid_targets.pick_random()
	new_target.is_targeted = true
	new_target._highlight_target()
	return new_target
