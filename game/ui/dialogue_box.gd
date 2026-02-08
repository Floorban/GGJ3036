class_name DialogueBox extends Control

@onready var float_root: NinePatchRect = %FloatRoot
@onready var label: Label = %Label
var lifetime := 5.0
var is_fading := false

func _ready() -> void:
	modulate.a = 0
	start_floating()
	get_tree().create_timer(lifetime).timeout.connect(fade_out)

func set_text(text: String, _font_size: int = 28) -> void:
	label.text = text

func fade_out() -> void:
	if is_fading:
		return
	is_fading = true

	if float_tween:
		float_tween.kill()

	if get_parent().has_method("remove_box"):
		get_parent().remove_box(self)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.2)
	tween.chain().tween_callback(queue_free)


var float_tween: Tween
var float_offset := 11.0
var float_duration := 2.6

func start_floating() -> void:
	if float_tween:
		float_tween.kill()

	float_tween = create_tween()
	float_tween.set_loops()
	float_tween.set_trans(Tween.TRANS_SINE)
	float_tween.set_ease(Tween.EASE_IN_OUT)

	float_tween.tween_property(
		float_root,
		"position:y",
		-float_offset,
		float_duration
	)

	float_tween.tween_property(
		float_root,
		"position:y",
		float_offset,
		float_duration
	)
