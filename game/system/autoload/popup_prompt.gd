extends Node

func display_prompt(_str : String, value: int,  pos: Vector2, scale: float, duration: float = 0.35):
	var prompt = Label.new()
	
	prompt.global_position = pos + Vector2(-_str.length() * 3, -30)
	prompt.z_index = 10
	prompt.label_settings = LabelSettings.new()
	if value > 0:
		prompt.text = str(value * 5) + " " + _str
	else:
		prompt.text = _str
	prompt.scale = Vector2.ZERO * scale

	var settings = prompt.label_settings
	settings.font_size = 32

	var color = Color.SKY_BLUE * 1.5
	if scale >= 2.0:
		color = Color.RED * 1.5
		settings.font_size = 48

	settings.font_color = color
	settings.outline_color = Color.BLACK
	settings.outline_size = 8
	
	prompt.rotation = randf_range(-0.35, 0.35)
	prompt.modulate = Color(1, 1, 1, 1)
	
	call_deferred("add_child", prompt)
	await prompt.resized
	prompt.pivot_offset = Vector2(prompt.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(
		prompt, "scale", Vector2.ONE, duration / 2
	).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		prompt, "position:y", prompt.position.y - 16, duration / 2
	).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		prompt, "position:y", prompt.position.y + 16, duration / 2
	).set_ease(Tween.EASE_IN).set_delay(duration / 2)

	tween.tween_property(
		prompt, "scale", Vector2.ZERO, duration / 3
	).set_ease(Tween.EASE_IN).set_delay(duration)

	tween.tween_property(
		prompt, "modulate:a", 0.0, duration / 3
	).set_ease(Tween.EASE_IN).set_delay(duration)
	
	await tween.finished
	prompt.queue_free()
