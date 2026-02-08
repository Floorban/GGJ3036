extends Enemy


func start_round() -> void:
	super.start_round()
	await get_tree().create_timer(0.2).timeout
	DialogueManager.say("Your next opponnent is a damn mountain")
	await get_tree().create_timer(5.8).timeout
	DialogueManager.say("He will be hard to stop, your stuns won't work that well on him")
	await get_tree().create_timer(5.0).timeout
	DialogueManager.say("You don't want to get hit by this fatass so focus on your defense")
	await get_tree().create_timer(5.0).timeout
	DialogueManager.say("Dont rely too much on it tho, it might fail you sometimes ")
