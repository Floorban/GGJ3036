class_name transition_screen extends Sprite2D

var burn_mat : ShaderMaterial

func _ready() -> void:
	burn_mat = material
	if burn_mat:
		burn_mat.set_shader_parameter("progress", 0)
		burn_mat.set_shader_parameter("pixel_count", 512)

func cover() -> void:
	var tween := create_tween()
	tween.parallel().tween_method(update_radius,
		1,
		0,
		1.5
	)
	tween.parallel().tween_method(update_pixelated,
		200,
		512,
		1.5
	)

func burn() -> void:
	var tween := create_tween()
	tween.parallel().tween_method(update_pixelated,
		512,
		200,
		1.5
	)

	tween.parallel().tween_method(update_radius,
		0,
		1,
		1.5
	)

func update_radius(value: float):
	if burn_mat:
		burn_mat.set_shader_parameter("progress", value)

func update_pixelated(value: float):
	if burn_mat:
		burn_mat.set_shader_parameter("pixel_count", value)
