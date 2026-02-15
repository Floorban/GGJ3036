class_name TransitionScreen extends Sprite2D

@export var menu: Menu

var sfx_fire: String = "event:/Ambient/Fire"
var i_fire: FmodEvent

func _ready() -> void:
	if menu:
		menu.dialogue_end.connect(func():
			i_fire.set_parameter_by_name_with_label("Transition", "Combat", true)
			audio.clear_instance([i_fire], 5)
			)

func burn():
	if material and material is ShaderMaterial:
		var tween = create_tween()
		material.set_shader_parameter("position", Vector2.ZERO)
		tween.tween_method(update_radius, 0.0, 2.0, 1.0)

func cover():
	if material and material is ShaderMaterial:
		var tween = create_tween()
		material.set_shader_parameter("position", Vector2.ZERO)
		tween.tween_method(update_radius, 2.0, 0.0, 0.7)
		if !menu.skip_dialogue: i_fire = audio.play_instance(sfx_fire)

func black_screen():
	if material and material is ShaderMaterial:
		material.set_shader_parameter("radius", 0.0)

func update_radius(value: float):
	if material:
		material.set_shader_parameter("radius", value)
