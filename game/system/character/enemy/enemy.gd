class_name Enemy extends Character

#AUDIO
@export var sfx_die: String
@export var sfx_entry: String
@export var sfx_hurt: String

var next_target: Anatomy

func get_ready_to_battle() -> void:
	audio.play(sfx_entry)
	super.get_ready_to_battle()
	_perform_attack(next_target)
	arm.action_finished.connect(func(_blocking: bool): next_target = choose_target())

func _perform_attack(_target: Anatomy) -> void:
	can_action = false
	await get_tree().create_timer(punch_strength * 2).timeout
	if next_target:
		arm._on_arm_charge_finished(punch_strength * 3)
		arm.punch(
			punch_strength,
			next_target.global_position,
			func(): enemy_attack(next_target))
	else:
		next_target = choose_target()

func _on_action_ready() -> void:
	super._on_action_ready()
	_perform_attack(next_target)

func enemy_attack(attack_target: Anatomy) -> void:
	var crit := randf() < critical_chance
	var dmg := attack_damage
	if crit: dmg *= 3
	attack_target._unhighlight_target()
	attack_target.anatomy_hit.emit(dmg)
	hit.emit(dmg, crit)
