class_name Enemy extends Character

var next_target: Anatomy

func get_ready_to_battle() -> void:
	super.get_ready_to_battle()
	_perform_attack(next_target)
	arm.action_finished.connect(func(_blocking: bool): next_target = choose_target())

func _perform_attack(_target: Anatomy) -> void:
	can_action = false
	if next_target:
		arm.punch(
			next_target.global_position,
			func(): enemy_attack(next_target))
	else:
		next_target = choose_target()

func _on_action_ready() -> void:
	super._on_action_ready()
	_perform_attack(next_target)

func enemy_attack(attack_target: Anatomy) -> void:
	combat_component.attack(attack_target)
