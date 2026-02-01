class_name Anatomy extends Node2D

@export var is_out_of_place : float
@export var max_hp : float
@export var current_hp : float

func init_part() -> void:
	current_hp = max_hp

func set_hp(changed_amount: float) -> void:
	current_hp -= changed_amount
	if current_hp <= 0:
		part_dead()

func part_dead() -> void:
	is_out_of_place = true
