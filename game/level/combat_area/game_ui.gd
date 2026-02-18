class_name GameUI extends Control

@onready var timer_panel: MarginContainer = %TimerPanel

@onready var label_round_time_left: Label = %LabelRoundTimeLeft

func set_round_ui(time_left: float) -> void:
	label_round_time_left.text = str(int(time_left))

@onready var boss_name_banner: TextureRect = %BossNameBanner
@onready var boss_name_label: Label = %BossNameBanner/Label
var banner_tween : Tween

func show_boss_name(boss_name: String) -> void:
	if banner_tween and banner_tween.is_running():
		banner_tween.kill()

	boss_name_label.text = boss_name
	boss_name_banner.visible = true
	boss_name_banner.modulate.a = 1.0

	var viewport := get_viewport_rect().size
	var size := boss_name_banner.size

	var start_pos := Vector2(-size.x, -size.y)
	var mid_pos := Vector2(64, 0)
	var end_pos := Vector2(viewport.x + size.x, mid_pos.y)

	boss_name_banner.position = start_pos
	boss_name_banner.visible = true
	banner_tween = create_tween()
	banner_tween.set_trans(Tween.TRANS_QUAD)
	banner_tween.set_ease(Tween.EASE_OUT)
	
	banner_tween.tween_property(
		boss_name_banner,
		"position",
		mid_pos,
		1.2
	).set_ease(Tween.EASE_OUT)

	var drift_pos := mid_pos + Vector2(25, 0)

	banner_tween.tween_property(
		boss_name_banner,
		"position",
		drift_pos,
		5.0
	).set_ease(Tween.EASE_IN_OUT)

	banner_tween.parallel().tween_property(
		boss_name_banner,
		"position",
		end_pos,
		4.0
	).set_ease(Tween.EASE_IN)

	banner_tween.parallel().tween_property(
		boss_name_banner,
		"modulate:a",
		0.0,
		0.6
	).set_delay(1.2)

	banner_tween.finished.connect(func():
		boss_name_banner.visible = false
	)
