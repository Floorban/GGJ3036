class_name EnemyMinion extends Enemy

@export var minion_data : MinionData

func init_character() -> void:
	_init_anatomy_parts()
	_init_combat_component()
	get_anatomy_references()

func switch_target() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_randomize_minion()


func _init_anatomy_parts() -> void:
	super._init_anatomy_parts()
	_randomize_minion()


func _randomize_minion() -> void:
	max_health = 0
	var chosen_face = minion_data.face_varuabts.pick_random()
	face.texture = chosen_face
	var chosen_ear = minion_data.ear_variants.pick_random()
	var chosen_eye = minion_data.eye_variants.pick_random()
	var chosen_arm = minion_data.mouth_variants.pick_random()
	var chosen_leg = minion_data.nose_variants.pick_random()
	_assign_part(chosen_ear)
	_assign_part(chosen_eye)
	_assign_part(chosen_arm)
	_assign_part(chosen_leg)
	
	rebuild_stats()


func _assign_part(chosen_part: AnatomyData) -> void:
	for part in anatomy_parts:
		if part.anatomy_type == chosen_part.get_anatomy_type():
			part.apply_data(chosen_part)
			max_health += part.max_hp
