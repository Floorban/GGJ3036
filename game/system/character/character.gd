class_name Character extends Node2D

var opponent: Character
@onready var combat_component: CombatComponent = %CombatComponent
@export var attack_damage: float = 1.0
@export var attack_cooldown: float = 2.0

var anatomy_parts: Array[Anatomy]
@onready var eye_1: Anatomy = %Eye1
@onready var eye_2: Anatomy = %Eye2
@onready var ear_1: Anatomy = %Ear1
@onready var ear_2: Anatomy = %Ear2
@onready var nose: Anatomy = %Nose
@onready var mouth: Anatomy = %Mouth
var opponent_anatomy: Array[Anatomy]

@export var arm: Arm
var can_attack := false

func init_character() -> void:
	get_anatomy_references()
	_init_combat_component()
	_init_anatomy_parts()

func get_anatomy_references() -> void:
	for anatomy in get_tree().get_nodes_in_group("anatomy"):
		if anatomy.get_parent() != self:
			opponent_anatomy.append(anatomy)

func _init_combat_component() -> void:
	combat_component.combat_ready.connect(_on_attack_ready)
	arm.action_finished.connect(_on_attack_finished)
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

func get_ready_to_battle() -> void:
	combat_component.combat_timer.start()

func _perform_attack(target: Anatomy) -> void:
	can_attack = false
	if target:
		arm.punch(
			target.global_position,
			func(): combat_component.attack(target))

func _on_attack_ready() -> void:
	can_attack = true

func _on_attack_finished() -> void:
	combat_component.combat_timer.start()

func choose_target() -> Anatomy:
	if opponent == null:
		return null

	var valid_targets := opponent.anatomy_parts.filter(
		func(part): return part.state != Anatomy.PartState.DESTROYED)

	if valid_targets.is_empty():
		_highlight_target(null)
		return null
		
	var new_target = valid_targets.pick_random()
	_highlight_target(new_target)
	return new_target

func _highlight_target(anatomy: Anatomy) -> void:
	for part in opponent_anatomy:
		if not part.is_part_dead():
			part.sprite.modulate = Color.WHITE

	if anatomy: anatomy.sprite.modulate = Color.RED
