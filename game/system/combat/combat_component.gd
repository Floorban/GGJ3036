class_name CombatComponent extends Node

signal combat_ready

var base_damage: float

@onready var combat_timer: Timer = %CombatTimer
@onready var action_cd_bar: TextureProgressBar = %ActionCooldownBar

func _ready() -> void:
	combat_timer.one_shot = true
	combat_timer.timeout.connect(_on_combat_timer_out)
	action_cd_bar.pivot_offset = action_cd_bar.size * 0.5

func _process(_delta: float) -> void:
	if combat_timer.is_stopped():
		return
	action_cd_bar.value = combat_timer.wait_time - combat_timer.time_left

func start() -> void:
	combat_timer.start()
	action_cd_bar.modulate = Color.WEB_GRAY

func _on_combat_timer_out() -> void:
	combat_ready.emit()
	
	action_cd_bar.modulate = Color.WHITE
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		action_cd_bar,
		"scale",
		Vector2.ONE * 1.5,
		0.15
	)

	tween.tween_property(
		action_cd_bar,
		"scale",
		Vector2.ONE,
		0.1
	)

func reset_attack_timer(cooldown: float) -> void:
	combat_timer.wait_time = cooldown
	action_cd_bar.max_value = combat_timer.wait_time
