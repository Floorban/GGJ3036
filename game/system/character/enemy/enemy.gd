class_name Enemy extends Character

var round_index := 0

@export var is_minion := false

@export var switch_chance := 0.5
@export var min_switch_time := 3.0

var next_target: Anatomy
var can_switch_target := false

func _ready() -> void:
	combat_component.start_counting.connect(swtic_target_timer)

func _process(delta: float) -> void:
	if is_dead or not can_control or is_stuned:
		return
	super._process(delta)
	switch_target()

func get_ready_to_battle() -> void:
	audio.play(sfx_entry)
	super.get_ready_to_battle()
	_perform_attack(next_target)
	#arm.action_finished.connect(func(_blocking: bool): next_target = choose_target())
	if not arm.action_finished.is_connected(_on_action_finished):
		arm.action_finished.connect(_on_action_finished)

func start_round() -> void:
	super.start_round()
	if next_target:
		next_target.is_targeted = false
		next_target._unhighlight_target()
		
func _on_action_finished(_blocking: bool) -> void:
	if is_dead: return
	super._on_action_finished(_blocking)
	if targeting_part:
		targeting_part.is_targeted = false
		targeting_part._unhighlight_target()
	next_target = choose_target()
	reveal_target_with_delay(next_target)

func switch_target() -> void:
	if not next_target:
		return
	if next_target.is_blocking and can_switch_target and abs(combat_component.combat_timer.wait_time - combat_component.combat_timer.time_left) < min_switch_time:
		next_target.is_targeted = false
		next_target._unhighlight_target()
		can_switch_target = false
		next_target = choose_target()

func swtic_target_timer(duration: float) -> void:
	if randf() < switch_chance:
		can_switch_target = true

func _perform_attack(_target: Anatomy) -> void:
	if not can_control:
		_target.is_targeted = false
		_target._unhighlight_target()
		return
	can_action = false
	await get_tree().create_timer(punch_strength * 2).timeout
	
	if next_target and not is_dead:
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
	if not can_control or rest_mode or is_dead:
		attack_target.is_targeted = false
		attack_target._unhighlight_target()
		arm.rest_pos()
		next_target = null
		return
	var crit := randf() < critical_chance
	var dmg := attack_damage
	if crit: dmg *= critical_damage
	attack_target.is_targeted = false
	attack_target._unhighlight_target()
	attack_target.anatomy_hit.emit(dmg, crit)
	hit.emit(dmg, crit)
