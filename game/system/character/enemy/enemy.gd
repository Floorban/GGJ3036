class_name Enemy extends Character

var next_target: Anatomy

func _perform_attack() -> void:
	if next_target:
		combat_component.attack(next_target)
	await get_tree().create_timer(0.2).timeout
	next_target = choose_target()
