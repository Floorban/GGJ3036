extends Node

## Combat Tutorial
var self_part_broken: bool = false
var enemy_part_broken: bool = false

## Surgery Tutorial
var entered_surgery: bool = false


func combat_control() -> void:
	pass


func self_broken_part() -> void:
	if self_part_broken:
		return
	self_part_broken = true
	await get_tree().create_timer(0.5).timeout
	DialogueManager.say("YESS Keep punching him!")
	await get_tree().create_timer(2.0).timeout
	DialogueManager.say("You gotta punch that part out out place!")
	await get_tree().create_timer(0.25).timeout
	await DialogueManager.wait_for_dialogue_continue()
	await get_tree().create_timer(2.0).timeout
	DialogueManager.clear_all_text_boxes()


func enemy_broken_part() -> void:
	if enemy_part_broken:
		return
	enemy_part_broken = true
	await get_tree().create_timer(0.5).timeout
	DialogueManager.say("YESS Keep punching him!")
	await get_tree().create_timer(2.0).timeout
	DialogueManager.say("You gotta punch that part out out place!")
	await get_tree().create_timer(0.25).timeout
	await DialogueManager.wait_for_dialogue_continue()
	await get_tree().create_timer(2.0).timeout
	DialogueManager.clear_all_text_boxes()


func surgery_intro() -> void:
	if DialogueManager.hide_dialogue: return
	
	entered_surgery = true
	await get_tree().create_timer(0.5).timeout
	DialogueManager.say("YOU GOT EM, GOOD FUCKING JOB DUDE !!")
	await get_tree().create_timer(0.25).timeout
	await DialogueManager.wait_for_dialogue_continue()
	DialogueManager.say("SO, this is the surgery room, all fancy and stuff.")
	await get_tree().create_timer(0.25).timeout
	await DialogueManager.wait_for_dialogue_continue()
	DialogueManager.say("If your parts are destroyed (purple), you can throw em away and get new ones.")
	await get_tree().create_timer(0.25).timeout
	await DialogueManager.wait_for_dialogue_continue()
	DialogueManager.say("You can still reattach the brown parts, they're not too fucked up.")
	await get_tree().create_timer(0.25).timeout
	await DialogueManager.wait_for_dialogue_continue()
	DialogueManager.say("Gotta remove the healthy part from your face first if there's not enough spot for it.")
	await DialogueManager.wait_for_dialogue_continue()
	DialogueManager.say("maybe you can even look a bit less ugly after fixing it.")
	await get_tree().create_timer(2.0).timeout
	DialogueManager.clear_all_text_boxes()
	
