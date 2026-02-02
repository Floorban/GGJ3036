class_name Enemy extends Character

var next_target: Anatomy

func get_ready_to_battle() -> void:
	super.get_ready_to_battle()
	_perform_attack(choose_target())

func _perform_attack(target: Anatomy) -> void:
	can_attack = false
	if next_target:
		arm.punch(
			next_target.global_position,
			func(): enemy_attack(next_target))
	else:
		next_target = target

func _on_attack_ready() -> void:
	super._on_attack_ready()
	_perform_attack(choose_target())

func enemy_attack(attack_target: Anatomy) -> void:
	combat_component.attack(attack_target)
	await get_tree().create_timer(0.2).timeout
	next_target = choose_target()
