extends Enemy

var eric_start := false

func start_round() -> void:
	if eric_start:
		eric_start = false
		await get_tree().create_timer(15.0).timeout
		super.start_round()
	else:
		super.start_round()

func init_character() -> void:
	if DialogueManager.hide_dialogue:
		super.init_character()
	else:
		_init_anatomy_parts()
		_init_combat_component()
		get_anatomy_references()
		await get_tree().create_timer(1.0).timeout
		DialogueManager.say("This multi eyed beast.. he will take a bit of time to prepare his attack")
		await Tutorial.wait_for_action()
		DialogueManager.say("but dont give him the chance, once he starts attacking")
		await Tutorial.wait_for_action()
		DialogueManager.say("HE WON'T STOP")
		await get_tree().create_timer(2.0).timeout
		enemy_dialogue_end.emit()
