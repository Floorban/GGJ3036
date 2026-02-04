class_name Bully extends Enemy
#
#func choose_target() -> Anatomy:
	#if not can_control and next_target:
		#next_target.is_targeted = false
		#next_target._unhighlight_target()
		#return
	#if opponent == null:
		#targeting_part = null
		#return null
#
	#var valid_targets := opponent.anatomy_parts.filter(
		#func(part): return part.state != Anatomy.PartState.DESTROYED and (part.name == "Nose" or part.name == "Mouth"))
#
	#if valid_targets.is_empty():
		#targeting_part = null
		#return null
		#
	#var new_target: Anatomy = valid_targets.pick_random()
	#targeting_part = new_target
	#targeting_part.is_targeted = true
	#targeting_part._highlight_target()
	#return new_target
