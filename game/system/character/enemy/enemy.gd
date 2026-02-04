class_name Enemy extends Character

var next_target: Anatomy

#AUDIO
@export var sfx_die: String
@export var sfx_entry: String
@export var sfx_hurt: String

func get_ready_to_battle() -> void:
	audio.play(sfx_entry)
	super.get_ready_to_battle()
	_perform_attack(next_target)
	arm.action_finished.connect(func(_blocking: bool): next_target = choose_target())

func _perform_attack(_target: Anatomy) -> void:
	if not can_control:
		_target.is_targeted = false
		_target._unhighlight_target()
		return
	can_action = false
	await get_tree().create_timer(punch_strength * 2).timeout
	if next_target:
		next_target.is_targeted = true
		next_target._highlight_target()
		arm._on_arm_charge_finished(punch_strength * 3)
		arm.punch(
			punch_strength,
			next_target.global_position,
			func(): enemy_attack(next_target))
	else:
		next_target = choose_target()

func _on_action_ready() -> void:
	super._on_action_ready()
	if not can_control:
		if next_target:
			next_target.is_targeted = false
			next_target._unhighlight_target()
		return
	if not is_stuned:
		_perform_attack(next_target)

func enemy_attack(attack_target: Anatomy) -> void:
	if not can_control:
		attack_target.is_targeted = false
		attack_target._unhighlight_target()
		return
	var crit := randf() < critical_chance
	var dmg := attack_damage
	if crit: dmg *= 3
	attack_target._unhighlight_target()
	attack_target.anatomy_hit.emit(dmg)
	hit.emit(dmg, crit)
