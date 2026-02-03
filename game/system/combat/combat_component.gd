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
	attack_cd_bar.value = combat_timer.time_left

func start() -> void:
	combat_timer.start()

func _on_combat_timer_out() -> void:
	combat_ready.emit()

func reset_attack_timer(cooldown: float) -> void:
	combat_timer.wait_time = cooldown
	attack_cd_bar.max_value = combat_timer.wait_time
