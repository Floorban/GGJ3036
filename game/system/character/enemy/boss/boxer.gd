extends Enemy

func start_round() -> void:
	super.start_round()
	await get_tree().create_timer(1.0).timeout
	DialogueManager.say("Wait till your arm charges up")
	await get_tree().create_timer(5.8).timeout
	DialogueManager.say("Then you can punch him or block")
	await get_tree().create_timer(5.0).timeout
	DialogueManager.say("Don't always block at one place")
	await get_tree().create_timer(5.0).timeout
	DialogueManager.say("This motherfucker would change the target")
