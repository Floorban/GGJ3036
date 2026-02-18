extends Enemy

func init_character() -> void:
	if DialogueManager.hide_dialogue:
		super.init_character()
	else:
		_init_anatomy_parts()
		_init_combat_component()
		get_anatomy_references()
		await get_tree().create_timer(1.0).timeout
		DialogueManager.say("Wait till your arm charges up")
		await DialogueManager.wait_for_dialogue_continue()
		DialogueManager.say("Then you can punch him or block (click your own parts)")
		await DialogueManager.wait_for_dialogue_continue()
		DialogueManager.say("Don't always block at one place")
		await DialogueManager.wait_for_dialogue_continue()
		DialogueManager.say("This motherfucker would change the target")
		await get_tree().create_timer(3.0).timeout
		enemy_dialogue_end.emit()
