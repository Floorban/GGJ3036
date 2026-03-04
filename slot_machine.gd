class_name SlotMachine extends Node2D

signal interacted()
signal spawn_part(part: Anatomy)

@export_group("Pools")
@export var parts_pool : Array[PackedScene]
@export var icon_map : Dictionary 

@export_group("Tweens")
var punch_tween : Tween
var slot_tweens : Array[Tween] = [null, null, null]
var bar_tween : Tween
var produce_tween : Tween

@onready var machine_base: Sprite2D = %MachineBase
@onready var machine_slots : Array[Sprite2D] = [%Slot1, %Slot2, %Slot3]
@onready var bar: Sprite2D = %Bar
@onready var pipe: Sprite2D = %Pipe
@onready var spawn_pos: Marker2D = %SpawnPos

@onready var bar_interact_area: Area2D = %BarInteractArea
var player_arm : Arm

var is_hovered := false
var is_spinning := false

## Audio
var sfx_activate: String = "event:/SFX/Slot/Activate"
var sfx_spit: String = "event:/SFX/Slot/Spit"

func _ready() -> void:
	player_arm = (get_tree().get_first_node_in_group("player") as Player).arm
	bar_interact_area.mouse_entered.connect(_on_hovered)
	bar_interact_area.mouse_exited.connect(_on_exited)
	_on_exited()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click") and not is_spinning and is_hovered:
		_start_arm_punch()


func _start_arm_punch() -> void:
	if player_arm == null:
		return
	
	player_arm.movable_by_mouse = false
	player_arm.punch(0.04, global_position + Vector2(randf_range(-10, 10), randf_range(-10, -30)), _on_machine_interact)


func _on_machine_interact() -> void:
	is_spinning = true
	interacted.emit()
	
	_animate_bar()
	_animate_punch()
	
	var part_scene = _get_random_part()
	var temp_instance = part_scene.instantiate() as Anatomy
	var result_type = temp_instance.anatomy_type
	temp_instance.queue_free()
	
	_spin_slots(result_type, part_scene)
	
	await get_tree().create_timer(0.5).timeout
	player_arm.movable_by_mouse = true


func _animate_bar() -> void:
	if bar_tween: bar_tween.kill()
	bar_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	bar_tween.tween_property(bar, "rotation_degrees", 80.0, 0.15)
	bar_tween.tween_property(bar, "rotation_degrees", 0.0, 0.3)


func _animate_punch() -> void:
	if punch_tween: punch_tween.kill()
	punch_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	punch_tween.tween_property(self, "position:x", position.x - 10, 0.05)
	punch_tween.tween_property(self, "position:x", position.x + 10, 0.05)
	punch_tween.tween_property(self, "position:x", position.x, 0.05)
	
	punch_tween.parallel().tween_property(machine_base, "scale", Vector2(1.3, 0.7), 0.1)
	punch_tween.tween_property(machine_base, "scale", Vector2.ONE, 0.2)


func _spin_slots(final_type: Anatomy.AnatomyType, part_to_spawn: PackedScene) -> void:
	var textures = icon_map.values()
	audio.play(self, sfx_activate)
	
	for i in range(machine_slots.size()):
		var slot = machine_slots[i]
		var loop_tween = create_tween().set_loops(10 + (i * 5))
		loop_tween.tween_callback(func(): 
			slot.texture = textures.pick_random()
			slot.scale = Vector2(1.3, 0.7)
			create_tween().tween_property(slot, "scale", Vector2.ONE, 0.05)
		).set_delay(0.08)
		
		loop_tween.finished.connect(func():
			slot.texture = icon_map[final_type]
			slot.scale = Vector2(1.8, 1.8)
			create_tween().set_trans(Tween.TRANS_BOUNCE).tween_property(slot, "scale", Vector2.ONE * 1.3, 0.2)
			if i == machine_slots.size() - 1:
				_produce_item(part_to_spawn)
		)


func _produce_item(part_scene: PackedScene) -> void:
	await get_tree().create_timer(0.5).timeout
	var new_part = part_scene.instantiate() as Anatomy
	GameManager.rest_room.background.add_child(new_part)
	
	new_part.global_position = pipe.global_position
	new_part.rotation = randf_range(-0.5, 0.5)
	new_part.z_index = 500
	
	var pipe_tween = create_tween()
	pipe_tween.tween_property(pipe, "scale", Vector2(1.8, 0.5), 0.15)
	pipe_tween.tween_property(pipe, "scale", Vector2.ONE, 0.2)
	
	_item_produced_effect(new_part)
	spawn_part.emit(new_part)
	is_spinning = false
	audio.play(self, sfx_spit)


func _item_produced_effect(part: Anatomy) -> void:
	if produce_tween: produce_tween.kill()
	var og_scale := part.scale
	part.spawn_blood_parc()
	
	produce_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	produce_tween.tween_property(part, "global_position", spawn_pos.global_position, 0.5)
	produce_tween.parallel().tween_property(part, "rotation_degrees", 360.0 + randf_range(0, 360), 0.45)
	
	produce_tween.tween_property(part, "scale", og_scale * Vector2(1.3, 1.3), 0.1)
	produce_tween.tween_property(part, "scale", og_scale, 0.15)
	produce_tween.tween_callback(_item_placement.bind(part))


func _item_placement(part: Anatomy) -> void:
	part.state = Anatomy.PartState.OutOfBody
	if not part.disconnect.is_connected(_on_part_disconnected):
		part.disconnect.connect(_on_part_disconnected.bind(part))


func _on_part_disconnected(part: Anatomy) -> void:
	part.body_owner = null
	part.reparent(GameManager.rest_room.background)
	part.z_index = 500


func _get_random_part() -> PackedScene:
	return parts_pool.pick_random()


func _on_hovered() -> void:
	is_hovered = true
	bar.use_parent_material = false


func _on_exited() -> void:
	is_hovered = false
	bar.use_parent_material = true
