class_name CombatComponent extends Node

signal attack_windup(progress: float)
signal combat_ready

var base_damage: float

@onready var combat_timer: Timer = %CombatTimer

func _ready() -> void:
	combat_timer.timeout.connect(_on_combat_timer_out)

func _process(_delta: float) -> void:
	if combat_timer.is_stopped():
		return

	var progress := 1.0 - (combat_timer.time_left / combat_timer.wait_time)
	attack_windup.emit(progress)

func _on_combat_timer_out() -> void:
	combat_ready.emit()

func attack(target: Anatomy) -> void:
	if target == null:
		push_error("no target to attack")
		return
	target.set_hp(base_damage)

func reset_attack_timer(attack_cooldown: float) -> void:
	combat_timer.wait_time = attack_cooldown
	combat_timer.start()
