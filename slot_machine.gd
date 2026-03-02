class_name SlotMachine extends Node2D

signal interacted()
signal spawn_part(part: Anatomy)


@export var parts_pool : Array[PackedScene]

var punch_tween : Tween
var slot_tween : Tween
var bar_tween : Tween
var produce_tween : Tween

@onready var machine_base: Sprite2D = %MachineBase
@onready var machine_slots : Array[Sprite2D] = [%Slot1, %Slot2, %Slot3]
@onready var bar: Sprite2D = %Bar
@onready var pipe: Sprite2D = %Pipe
@onready var spawn_pos: Marker2D = %SpawnPos


@export var slot_icons_pool : Array[Texture2D]

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("right_click"):
		on_machine_interact()


func on_machine_interact() -> void:
	machine_punched_effect()
	interacted.emit()


func machine_punched_effect() -> void:
	_bar_rotate()
	#_slots_rotate()
	if punch_tween:
		punch_tween.kill()
	
	var og_pos = position
	
	punch_tween = create_tween().set_ease(Tween.EASE_OUT)
	# animate the slot machine being punched swing and scale effect
	punch_tween.tween_property(self, "position", og_pos + Vector2.LEFT * 20, 0.1)
	punch_tween.tween_property(self, "position", og_pos + Vector2.RIGHT * 20, 0.1)
	punch_tween.tween_property(self, "position", og_pos, 0.1)
	punch_tween.tween_property(machine_base, "scale", Vector2(1.2, 0.8), 0.2)
	punch_tween.tween_property(machine_base, "scale", Vector2.ONE, 0.1)
	punch_tween.tween_callback(_produce_item)


func _slots_rotate() -> void:
	if slot_tween:
		slot_tween.kill()
	
	slot_tween = create_tween()


func _slots_end(outcome: Anatomy.AnatomyType) -> void:
	if outcome == Anatomy.AnatomyType.Eye:
		pass
	elif outcome == Anatomy.AnatomyType.Ear:
		pass
	elif outcome == Anatomy.AnatomyType.Nose:
		pass
	elif outcome == Anatomy.AnatomyType.Mouth:
		pass
	else:
		pass


func _bar_rotate() -> void:
	if bar_tween:
		bar_tween.kill()
	
	bar_tween = create_tween().set_trans(Tween.TRANS_EXPO)
	bar_tween.tween_property(bar, "rotation_degrees", -20, 0.07)
	bar_tween.tween_property(bar, "rotation_degrees", 80.0, 0.15)
	bar_tween.tween_property(bar, "rotation_degrees", 0.0, 0.2)
	#rotate bar


func _produce_item() -> void:
	var new_part = _get_random_part().instantiate() as Anatomy
	_slots_end(new_part.anatomy_type)
	GameManager.rest_room.background.add_child(new_part)
	new_part.global_position = pipe.global_position
	new_part.rotation = randf_range(-5, 5)
	new_part.z_index = 500
	_item_produced_effect(new_part)
	spawn_part.emit(new_part)


func _item_produced_effect(part: Anatomy) -> void:
	if produce_tween:
		produce_tween.kill()
	
	var og_scale := part.scale
	
	produce_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	# animate the pipe and slide the item out
	
	produce_tween.tween_property(part, "global_position", spawn_pos.global_position, 0.1)
	produce_tween.tween_property(part, "scale", part.scale * Vector2(1.4, 0.6), 0.15)
	produce_tween.tween_property(part, "scale", og_scale, 0.1)
	produce_tween.tween_callback(_item_placement.bind(part))


func _item_placement(part: Anatomy) -> void:
	part.disconnect.connect(func(): 
		part.body_owner = null
		part.reparent(GameManager.rest_room.background)
		part.z_index = 500
	)
	part.state = Anatomy.PartState.OutOfBody


func _get_random_part() -> PackedScene:
	if parts_pool.is_empty():
		push_error("no parts in the pool")
		return null
	
	var picked_part = parts_pool.pick_random()
	return picked_part
