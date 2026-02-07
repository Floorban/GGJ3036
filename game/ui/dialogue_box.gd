class_name DialogueBox extends Control

@onready var label: Label = %Label
var lifetime := 5.0
var is_fading := false

func _ready() -> void:
	modulate.a = 0
	get_tree().create_timer(lifetime).timeout.connect(fade_out)

func set_text(text: String) -> void:
	label.text = text

func fade_out() -> void:
	if is_fading: return
	is_fading = true
	
	if get_parent().has_method("remove_box"):
		get_parent().remove_box(self)
		
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.2)
	tween.chain().tween_callback(queue_free)
