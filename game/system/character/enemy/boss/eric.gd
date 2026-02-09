extends Enemy

var eric_start := false

func start_round() -> void:
	await get_tree().create_timer(10.0).timeout
	super.start_round()

func init_character() -> void:
	_init_anatomy_parts()
	_init_combat_component()
	get_anatomy_references()
	await get_tree().create_timer(1.0).timeout
	DialogueManager.say("This multi eyed beast.. he will take a bit of time to prepare his attack")
	await DialogueManager.wait_for_dialogue_continue()
	DialogueManager.say("but dont give him the chance, once he starts attacking")
	await DialogueManager.wait_for_dialogue_continue()
	DialogueManager.say("HE WON'T STOP")
	await get_tree().create_timer(2.0).timeout
	enemy_dialogue_end.emit()
