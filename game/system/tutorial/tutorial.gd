extends Node
class_name Tutorial

## Combat
var self_part_broken: bool = false
var enemy_part_broken: bool = false

## Idle
var entered_surgery: bool = false

func tutorial_self_broken_part() -> void:
	return

func tutorial_enemy_broken_part() -> void:
	return

func tutorial_enter_surgery() -> void:
	if DialogueManager.hide_dialogue: return
	
	entered_surgery = true
	await get_tree().create_timer(0.5).timeout
	DialogueManager.say("YOU GOT EM, GOOD FUCKING JOB DUDE !!")
	await get_tree().create_timer(0.25).timeout
	await DialogueManager.wait_for_dialogue_continue()
	DialogueManager.say("SO, this is the surgery room, all fancy and stuff.")
	await get_tree().create_timer(0.25).timeout
	await DialogueManager.wait_for_dialogue_continue()
	DialogueManager.say("If your parts are destroyed (purple), you can throw em away and get new ones.", 12.0)
	await get_tree().create_timer(0.25).timeout
	await DialogueManager.wait_for_dialogue_continue()
	DialogueManager.say("You can still reattach the brown parts, they're not too fucked up.", 15.0)
	await get_tree().create_timer(0.25).timeout
	await DialogueManager.wait_for_dialogue_continue()
	DialogueManager.say("Gotta remove the healthy part from your face first if there's not enough spot for it.")
	await get_tree().create_timer(1.5).timeout
	DialogueManager.say("maybe you can even look a bit less ugly after fixing it.")
