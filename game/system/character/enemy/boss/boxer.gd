extends Enemy

func init_character() -> void:
	if DialogueManager.hide_dialogue:
		super.init_character()
	else:
		_init_anatomy_parts()
		_init_combat_component()
		get_anatomy_references()
		await get_tree().create_timer(1.0).timeout
		DialogueManager.say("Ahhh this guy....")
		await Tutorial.wait_for_action()
		DialogueManager.say("Don't always block at one place")
		await Tutorial.wait_for_action()
		DialogueManager.say("This motherfucker would change the target")
		await get_tree().create_timer(3.0).timeout
		enemy_dialogue_end.emit()
