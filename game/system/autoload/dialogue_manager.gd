extends CanvasLayer

## Dialogue
@export var hide_dialogue := false
@export var dialogue_scene: PackedScene
@export var max_visible := 5
@export var spacing := 10
@export var base_offset := Vector2(100, -100)
var dialogues: Array[DialogueBox] = []
var lifetime_timers := {} # dictionary<DialogueBox, SceneTreeTimer>
var freeze_dialogue_boxes := false

## NPCs
enum NPC {
	UNKNOWN,
	COACH,
	DOCTOR,
	RON
}

var npc_icons := {
	NPC.UNKNOWN: preload("uid://blr3c8tlciihf"),
	NPC.COACH: preload("uid://7dj7ie6h0j7n"),
	NPC.DOCTOR: preload("res://sprites/body_parts/Basehead/Unknown.png"),
	NPC.RON: preload("res://sprites/body_parts/Basehead/Unknown.png"),
}

@onready var npc_icon: TextureRect = $NPC

## Sound
var sfx_chat: String = "event:/SFX/UI/Chat"

func _ready() -> void:
	npc_idle()

func wait_for_dialogue_continue() -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("left_click"):
			return

func say(text: String, npc: NPC = NPC.UNKNOWN, duration := 10.0) -> void:
	if not dialogue_scene: return
	npc_icon.texture = npc_icons.get(npc, npc_icons[NPC.UNKNOWN])
	
	npc_talk()
	var box := dialogue_scene.instantiate() as DialogueBox
	add_child(box)
	box.set_text(text)
	box.lifetime = duration
	dialogues.append(box)

	_start_lifetime(box, duration)
	if dialogues.size() > max_visible:
		var oldest = dialogues[0]
		if is_instance_valid(oldest): oldest.fade_out()

	audio.play(self, sfx_chat)

	await get_tree().process_frame
	_reflow()


func _start_lifetime(box: DialogueBox, duration: float) -> void:
	var weak_box : WeakRef  = weakref(box)
	var timer := get_tree().create_timer(duration)
	lifetime_timers[box] = timer

	timer.timeout.connect(func():
		var strong_box = weak_box.get_ref()
		if strong_box == null:
			return
		if strong_box not in dialogues:
			lifetime_timers.erase(strong_box)
			return

		if freeze_dialogue_boxes:
			_start_lifetime(strong_box, duration / 2)
		else:
			lifetime_timers.erase(strong_box)
			strong_box.fade_out()
	)


func tooltip(tooltip: Tooltip) -> String:
	var text_image = "[img=32x32]" + tooltip.icon.resource_path + "[/img] "
	var text_line: String = tooltip.text + ""

	var text = text_line + text_image
	return text

func _reflow() -> void:
	dialogues = dialogues.filter(func(box): return is_instance_valid(box) and not box.is_fading)

	var view_h = get_viewport().get_visible_rect().size.y
	var current_y = view_h + base_offset.y
	
	for i in range(dialogues.size() - 1, -1, -1):
		var box = dialogues[i]
		var box_height = box.get_child(0).size.y 
		dialogues[dialogues.size() - 1].global_position.y = view_h + base_offset.y - box_height
		current_y -= box_height
		
		var target_pos = Vector2(base_offset.x, current_y)
		var tween = create_tween().set_parallel(true)
		tween.tween_property(box, "position", target_pos, 0.35).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.tween_property(box, "modulate:a", 1.0, 0.5)
		
		current_y -= spacing


func clear_all_text_boxes() -> void:
	for box in dialogues.duplicate():
		if box in lifetime_timers:
			lifetime_timers.erase(box)
		await get_tree().create_timer(0.3).timeout
		box.fade_out()
	dialogues.clear()
	lifetime_timers.clear()


func remove_box(box: DialogueBox) -> void:
	if box in lifetime_timers:
		lifetime_timers.erase(box)
	if box in dialogues:
		dialogues.erase(box)
		_reflow()
		
	if dialogues.is_empty(): npc_idle()

var talking_tween: Tween
var idle_modulate := Color(0.132, 0.132, 0.132, 0.0)
var talking_modulate := Color(1, 1, 1, 1)

func npc_talk() -> void:
	if talking_tween:
		talking_tween.kill()
	
	talking_tween = create_tween()
	talking_tween.set_parallel(true)
	
	npc_icon.scale = Vector2.ONE
	talking_tween.tween_property(npc_icon, "scale", Vector2(1.15, 1.15), 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	npc_icon.rotation_degrees = 0
	talking_tween.tween_property(npc_icon, "rotation_degrees", randf_range(-15, 15), 0.15)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	talking_tween.tween_property(npc_icon, "modulate", talking_modulate, 0.15)
	talking_tween.tween_property(npc_icon, "rotation_degrees", 0, 0.3)\
		.set_delay(0.12)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

func npc_idle() -> void:
	if talking_tween:
		talking_tween.kill()
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(npc_icon, "scale", Vector2.ONE, 0.25)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(npc_icon, "rotation_degrees", 0, 0.25)
	tween.tween_property(npc_icon, "modulate", idle_modulate, 0.3)
