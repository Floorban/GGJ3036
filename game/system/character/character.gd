class_name Character extends Node2D

var opponent: Character
@onready var combat_component: CombatComponent = %CombatComponent
@export var attack_cooldown: float

var anatomy_parts: Array[Anatomy]
@onready var eye: Anatomy = %Eye
@onready var ear: Anatomy = %Ear
@onready var nose: Anatomy = %Nose
@onready var mouth: Anatomy = %Mouth

func init_character() -> void:
	_init_combat_component()
	_init_anatomy_parts()

func _init_combat_component() -> void:
	combat_component.combat_ready.connect(_perform_attack)
	combat_component.reset_attack_timer(attack_cooldown)

func _init_anatomy_parts() -> void:
	anatomy_parts.append(eye)
	anatomy_parts.append(ear)
	anatomy_parts.append(nose)
	anatomy_parts.append(mouth)
	for part in anatomy_parts:
		part.init_part()

func _perform_attack() -> void:
	var target := choose_target()
	combat_component.attack(target)

func choose_target() -> Anatomy:
	if opponent == null:
		return null

	var valid_targets := opponent.anatomy_parts.filter(
		func(part): return part.state != Anatomy.PartState.DESTROYED)

	if valid_targets.is_empty():
		return null

	return valid_targets.pick_random()
