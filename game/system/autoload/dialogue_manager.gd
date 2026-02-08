extends CanvasLayer

@export var dialogue_scene: PackedScene
@export var max_visible := 5
@export var spacing := 10
@export var base_offset := Vector2(100, -100)

var dialogues: Array[DialogueBox] = []

var sfx_chat: String = "event:/SFX/UI/Chat"

func wait_for_dialogue_continue() -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("left_click"):
			return

func say(text: String, duration := 10.0) -> void:
	if not dialogue_scene: return
	
	var box := dialogue_scene.instantiate() as DialogueBox
	add_child(box)
	box.set_text(text)
	box.lifetime = duration
	dialogues.append(box)
	
	if dialogues.size() > max_visible:
		var oldest = dialogues[0]
		if is_instance_valid(oldest): oldest.fade_out()
	
	audio.play(sfx_chat)

	await get_tree().process_frame
	_reflow()

func _reflow() -> void:
	dialogues = dialogues.filter(func(box): return is_instance_valid(box) and not box.is_fading)
	
	var view_h = get_viewport().get_visible_rect().size.y
	var current_y = view_h + base_offset.y
	
	for i in range(dialogues.size() - 1, -1, -1):
		var box = dialogues[i]
		
		var box_height = box.get_child(0).size.y 
		current_y -= box_height
		
		var target_pos = Vector2(base_offset.x, current_y)
		var tween = create_tween().set_parallel(true)
		tween.tween_property(box, "position", target_pos, 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.tween_property(box, "modulate:a", 1.0, 0.2)
		
		current_y -= spacing

func remove_box(box: DialogueBox) -> void:
	if box in dialogues:
		dialogues.erase(box)
		_reflow()
