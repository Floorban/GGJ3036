class_name CombatComponent extends Node

signal combat_ready

var base_damage: float

@onready var combat_timer: Timer = %CombatTimer
@onready var attack_cd_bar: ProgressBar = %AttackCooldownBar

func _ready() -> void:
	combat_timer.one_shot = true
	combat_timer.timeout.connect(_on_combat_timer_out)

func _process(_delta: float) -> void:
	if combat_timer.is_stopped():
		return

	var progress := 1.0 - (combat_timer.time_left / combat_timer.wait_time)
	attack_cd_bar.value = combat_timer.time_left

func _on_combat_timer_out() -> void:
	combat_ready.emit()

func attack(target: Anatomy) -> void:
	if target == null:
		push_error("no target to attack")
		return
	if target.is_blocking:
		target.is_blocking = false
	else:
		target.set_hp(base_damage)
		target.is_targeted = false

func reset_attack_timer(attack_cooldown: float) -> void:
	combat_timer.wait_time = attack_cooldown
	attack_cd_bar.max_value = combat_timer.wait_time
