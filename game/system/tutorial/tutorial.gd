extends Node

@export var left_click: Tooltip
@export var right_click: Tooltip
@export var left_hold: Tooltip
@export var left_release: Tooltip

## Combat Tutorial
var entered_combat: bool = false
var self_part_broken: bool = false
var enemy_part_broken: bool = false

## Surgery Tutorial
var entered_surgery: bool = false


func combat_intro() -> void:
	if DialogueManager.hide_dialogue: return
	
	await get_tree().create_timer(2.0).timeout
	var box1 = await DialogueManager.say("Remember how to punch this motherfucker right?")
	await wait_for_action()
	DialogueManager.remove_static_box(box1)
	DialogueManager.say(DialogueManager.tooltip_text(left_click) + "on his face parts to attack")
	await wait_for_action()
	DialogueManager.say("(Hover over the icon to see detailed description)")
	await wait_for_action()
	#var box4 = await DialogueManager.say(DialogueManager.tooltip_text(right_click) + "to cancel your attack")
	#await wait_for_action()
	#DialogueManager.remove_static_box(box4)
	DialogueManager.say(DialogueManager.tooltip_text(left_click) + "on your face parts to block your opponent's attack")
	await wait_for_action()
	DialogueManager.say("NOW LOCK INNN ! ! !")
	await get_tree().create_timer(2.0).timeout
	GameManager.combat_area.enemy.begin_enemy()


func self_broken_part() -> void:
	if DialogueManager.hide_dialogue: return
	
	if self_part_broken:
		return
	self_part_broken = true
	await get_tree().create_timer(0.5).timeout
	DialogueManager.say("OHH NO! Where's your defense bro? !")
	await wait_for_action()
	DialogueManager.say(DialogueManager.tooltip_text(left_click) + "on your face parts to defend")
	await wait_for_action()
	DialogueManager.say("You can see his attacking intent in red on your parts")
	await wait_for_action()
	DialogueManager.say("Have to hold your arm on the right part to block his attack")
	await wait_for_action()
	await get_tree().create_timer(2.0).timeout
	DialogueManager.clear_all_text_boxes()


func enemy_broken_part() -> void:
	if DialogueManager.hide_dialogue: return
	
	if enemy_part_broken:
		return
	enemy_part_broken = true
	await get_tree().create_timer(0.5).timeout
	DialogueManager.say("YESS Keep punching him!")
	await wait_for_action()
	DialogueManager.say("You gotta punch that part out out place!")
	await wait_for_action()
	DialogueManager.say("There can only be one winner! ! Kill him or wait to be killed")
	await wait_for_action()
	await get_tree().create_timer(2.0).timeout
	DialogueManager.clear_all_text_boxes()


func surgery_intro() -> void:
	if DialogueManager.hide_dialogue: return
	
	entered_surgery = true
	await get_tree().create_timer(0.5).timeout
	DialogueManager.say("YOU GOT EM, GOOD FUCKING JOB DUDE !!")
	await wait_for_action()
	DialogueManager.say("SO, this is the surgery room, all fancy and stuff.")
	await wait_for_action()
	DialogueManager.say("If your parts are destroyed (purple), you can throw em away and get new ones.")
	await wait_for_action()
	DialogueManager.say("You can still reattach the brown parts, they're not too fucked up.")
	await wait_for_action()
	DialogueManager.say("Remove the part from your face first if there's not enough spot for it.")
	await wait_for_action()
	DialogueManager.say(DialogueManager.tooltip_text(left_hold) + "the parts to move them around")
	await wait_for_action()
	DialogueManager.say(DialogueManager.tooltip_text(left_release) + "to drop the part")
	await wait_for_action(ACTION_TYPES.LEFT_RELEASE)
	DialogueManager.say("maybe you can even look a bit less ugly after fixing it.")
	await get_tree().create_timer(3.0).timeout
	DialogueManager.clear_all_text_boxes()


enum ACTION_TYPES{
	ANY,
	LEFT_PRESS,
	LEFT_RELEASE,
	RIGHT_PRESS
}


func wait_for_action(action: ACTION_TYPES = ACTION_TYPES.ANY) -> void:
	await get_tree().create_timer(0.25).timeout
	while true:
		await get_tree().process_frame
		if action == ACTION_TYPES.ANY:
			if Input.is_anything_pressed():
				return
		elif action == ACTION_TYPES.LEFT_PRESS:
			if Input.is_action_just_pressed("left_click"):
				return
		elif action == ACTION_TYPES.LEFT_RELEASE:
			if Input.is_action_just_released("left_click"):
				return
		elif action == ACTION_TYPES.RIGHT_PRESS:
			if Input.is_action_just_pressed("right_click"):
				return
