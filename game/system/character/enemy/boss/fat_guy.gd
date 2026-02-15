extends Enemy

func init_character() -> void:
	if DialogueManager.hide_dialogue:
		super.init_character()
	else:
		_init_anatomy_parts()
		_init_combat_component()
		get_anatomy_references()
		await get_tree().create_timer(1.0).timeout
		DialogueManager.say("Your next opponnent is a damn mountain")
		await DialogueManager.wait_for_dialogue_continue()
		DialogueManager.say("He will be hard to stop, your stuns won't work that well on him")
		await DialogueManager.wait_for_dialogue_continue()
		DialogueManager.say("You don't want to get hit by this fatass so focus on your defense")
		await DialogueManager.wait_for_dialogue_continue()
		DialogueManager.say("Dont rely too much on it tho, it might fail you sometimes ")
		await get_tree().create_timer(3.0).timeout
		enemy_dialogue_end.emit()
