class_name EnemyMinion extends Enemy

@export var ear_variants: Array[AnatomyData]
@export var eye_variants: Array[AnatomyData]
@export var arm_variants: Array[AnatomyData]
@export var leg_variants: Array[AnatomyData]

func _randomize_minion() -> void:
	anatomy_parts.clear()
	max_health = 0
	
	var chosen_ear = ear_variants.pick_random()
	var chosen_eye = eye_variants.pick_random()
	var chosen_arm = arm_variants.pick_random()
	var chosen_leg = leg_variants.pick_random()
	_assign_part(chosen_ear)
	_assign_part(chosen_eye)
	_assign_part(chosen_arm)
	_assign_part(chosen_leg)

	rebuild_stats()

func _assign_part(chosen_part: AnatomyData) -> void:
	for part in anatomy_parts:
		if part.anatomy_type == chosen_part.anatomy_type:
			part.apply_data(chosen_part)
			break
