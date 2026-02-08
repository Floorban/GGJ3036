extends Enemy

func start_round() -> void:
	super.start_round()
	if next_target:
		next_target.is_targeted = false
		next_target._unhighlight_target()
	await get_tree().create_timer(1.0).timeout
	DialogueManager.say("Wait till your arm charges up")
	await DialogueManager.wait_for_dialogue_continue()
	DialogueManager.say("Then you can punch him or block")
	await DialogueManager.wait_for_dialogue_continue()
	DialogueManager.say("Don't always block at one place")
	await DialogueManager.wait_for_dialogue_continue()
	DialogueManager.say("This motherfucker would change the target")
	enemy_dialogue_end.emit()
