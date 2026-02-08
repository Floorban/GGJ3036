class_name Bully extends Enemy

func start_round() -> void:
	super.start_round()
	if round_index == 0:
		await get_tree().create_timer(0.8).timeout
		DialogueManager.say("Wait till your arm charges up")
		await get_tree().create_timer(2.8).timeout
		DialogueManager.say("Then you can punch him or block")
		await get_tree().create_timer(3.0).timeout
		DialogueManager.say("Don't always block at one place")
		await get_tree().create_timer(3.0).timeout
		DialogueManager.say("This mf would change the target")
	else:
		pass

func choose_target() -> Anatomy:
	if not can_control and next_target:
		next_target.is_targeted = false
		next_target._unhighlight_target()
		return
	if opponent == null:
		targeting_part = null
		return null

	var valid_targets := opponent.anatomy_parts.filter(
		func(part): return part.state != Anatomy.PartState.DESTROYED and (part.name == "Nose" or part.name == "Mouth"))

	if valid_targets.is_empty():
		targeting_part = null
		return null
		
	var new_target: Anatomy = valid_targets.pick_random()
	targeting_part = new_target
	if can_control:
		targeting_part.is_targeted = true
	targeting_part.is_targeted = true
	targeting_part._highlight_target()
	return new_target
