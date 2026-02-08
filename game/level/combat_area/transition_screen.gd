class_name transition_screen extends Sprite2D

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

func black_screen():
	if material and material is ShaderMaterial:
		material.set_shader_parameter("radius", 0.0)

func update_radius(value: float):
	if material:
		material.set_shader_parameter("radius", value)
