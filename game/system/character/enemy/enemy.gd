class_name Enemy extends Character

var next_target: Anatomy

func _perform_attack() -> void:
	if next_target:
		arm.punch(
			next_target.global_position,
			func(): enemy_attack(next_target))
	else:
		next_target = choose_target()

func enemy_attack(attack_target: Anatomy) -> void:
	combat_component.attack(attack_target)
	await get_tree().create_timer(0.2).timeout
	next_target = choose_target()
