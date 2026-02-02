class_name Character extends Node2D

var opponent: Character
@onready var combat_component: CombatComponent = %CombatComponent
@export var attack_damage: float = 1.0
@export var attack_cooldown: float = 2.0

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
	#arm.action_finished.connect(_on_action_finished)
	arm.action_finished.connect(func(blocking: bool): _on_action_finished(blocking))
	combat_component.base_damage = attack_damage
	combat_component.reset_attack_timer(attack_cooldown)

func _init_anatomy_parts() -> void:
	anatomy_parts.append(eye_1)
	anatomy_parts.append(eye_2)
	anatomy_parts.append(ear_1)
	anatomy_parts.append(ear_2)
	anatomy_parts.append(nose)
	anatomy_parts.append(mouth)
	for part in anatomy_parts:
		part.init_part()
		part.anatomy_damaged.connect(take_damage)

func get_ready_to_battle() -> void:
	combat_component.combat_timer.start()

func take_damage(damaged_amount: float) -> void:
	if blocking_part:
		_on_block_finished()
	else:
		pass

#func _perform_action(target: Anatomy) -> void:
	#if target in opponent_anatomy:
		#_perform_attack(target)
	#elif target in anatomy_parts:
		#_perform_block(target)

func _perform_attack(target: Anatomy) -> void:
	can_action = false
	if target:
		if blocking_part:
			blocking_part.is_blocking = false
		arm.punch(
			target.global_position,
			func(): combat_component.attack(target))

func _perform_block(target: Anatomy) -> void:
	if target:
		if blocking_part:
			blocking_part.is_blocking = false
		blocking_part = target
		blocking_part.is_blocking = true
		arm.block(target.global_position)

func _on_action_ready() -> void:
	can_action = true

func _on_action_finished(blocking: bool) -> void:
	if not blocking:
		if opponent.blocking_part:
			opponent.blocking_part = null
			arm.rest_pos()
			print("A")
		_on_attack_finished()

func _on_attack_finished() -> void:
	combat_component.combat_timer.start()

func _on_block_finished() -> void:
	combat_component.combat_timer.start()
	print("blocked" + blocking_part.name)
	arm.rest_pos()
	blocking_part.is_blocking = false
	blocking_part = null

func choose_target() -> Anatomy:
	if opponent == null:
		return null

	var valid_targets := opponent.anatomy_parts.filter(
		func(part): return part.state != Anatomy.PartState.DESTROYED)

	if valid_targets.is_empty():
		_highlight_target(null)
		return null
		
	var new_target: Anatomy = valid_targets.pick_random()
	new_target.is_targeted = true
	_highlight_target(new_target)
	return new_target

func _highlight_target(anatomy: Anatomy, block_target := false) -> void:
	for part in opponent_anatomy:
		if not part.is_part_dead():
			part.sprite.modulate = Color.WHITE

	if anatomy:
		if block_target:
			for part in anatomy_parts:
				if not part.is_part_dead() and part.is_blocking:
					part.sprite.modulate = Color.WHITE
				else:
					anatomy.sprite.modulate = Color.SKY_BLUE
		else:
			for part in anatomy_parts:
				if not part.is_part_dead():
					part.sprite.modulate = Color.WHITE
			anatomy.sprite.modulate = Color.RED
