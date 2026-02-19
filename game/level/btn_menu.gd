extends TextureButton

var sfx_confirm: String = "event:/SFX/UI/Confirm"
var sfx_hover: String = "event:/SFX/UI/Hover"

var tween: Tween

func _ready() -> void:
	mouse_entered.connect(_on_mouse_hover.bind(true))
	mouse_exited.connect(_on_mouse_hover.bind(false))
	pressed.connect(_pressed_effect)

func _on_mouse_hover(hovered: bool) -> void:
	reset_tween()
	tween.tween_property(self, "scale", Vector2.ONE * 1.2 if hovered else Vector2.ONE, 0.07)
	tween.tween_property(self, "rotation_degrees", 3.0 * [-1, 1].pick_random() if hovered else 0.0, 0.07)
	audio.play(self, sfx_hover)

func reset_tween() -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_parallel()


func _pressed_effect() -> void: audio.play(self, sfx_confirm)
