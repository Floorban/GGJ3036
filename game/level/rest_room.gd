class_name RestRoom extends Node2D

signal ready_to_fight()

@onready var background: Sprite2D = $Background
@onready var ready_button: Button = %ReadyButton

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var upgrades: Node2D = %Upgrades
@export var upgrade_scenes_by_tier: Dictionary = {
	1: [],
	2: [],
	3: [],
	4: [],
	5: []
}

func get_allowed_tiers(level: int) -> Array[int]:
	if level < 2:
		return [1, 2]
	elif level < 4:
		return [1, 2, 3]
	elif level < 6:
		return [2, 3, 4]
	elif level < 8:
		return [3, 4, 5]
	else:
		return [4, 5]

@export var upgrade_parts : Array[Anatomy]
@onready var part_spawn_markers: Array[Marker2D] = [%SpawnMarker1, %SpawnMarker2, %SpawnMarker3, %SpawnMarker4, %SpawnMarker5, %SpawnMarker6, %SpawnMarker7, %SpawnMarker8, %SpawnMarker9, %SpawnMarker10, %SpawnMarker11, %SpawnMarker12]

func _ready() -> void:
	Stats.rest_room = self
	ready_button.pressed.connect(leave_rest_room)
	leave_rest_room()

func enter_rest_room(current_level: int) -> void:
	if current_level % 2 == 0:
		clear_upgrade_parts()
	part_info_panel.visible = true
	background.visible = true
	ready_button.visible = true
	ready_button.mouse_filter = Control.MOUSE_FILTER_STOP
	audio.muffle(true, false)

	for part in player.anatomy_parts:
		if part.state == Anatomy.PartState.DESTROYED:
			part.body_owner = null
	await  get_tree().create_timer(0.1).timeout
	player.rest_mode = true
	spawn_parts(current_level)
	connect_parts_interact_signal()
	for p in background.get_children():
		p.z_index = 10

func leave_rest_room() -> void:
	part_info_panel.visible = false
	background.visible = false
	ready_button.visible = false
	ready_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	audio.muffle(true, true)
	for i in range(player.anatomy_parts.size() - 1, -1, -1):
		var part = player.anatomy_parts[i]
		if part.body_owner == null or part.state != Anatomy.PartState.HEALTHY:
			part.body_owner = null
			part.reparent(background)
			player.anatomy_parts.remove_at(i)
	if player.anatomy_parts.is_empty():
		assert(player.anatomy_parts.is_empty(), "can't start with no parts")
		return
	player.rest_mode = false
	ready_to_fight.emit()

func clear_upgrade_parts() -> void:
	for marker in part_spawn_markers:
		if not marker.get_children().is_empty():
			for c in marker.get_children():
				c.queue_free()
	for part in upgrade_parts:
		part.queue_free()
	upgrade_parts.clear()

var remaining_upgrade_pool: Array[PackedScene] = []

func get_upgrade_scene_pool(level: int) -> Array[PackedScene]: 
	var allowed_tiers := get_allowed_tiers(level) 
	var pool: Array[PackedScene] = [] 
	for tier in allowed_tiers: if upgrade_scenes_by_tier.has(tier):
		for s in upgrade_scenes_by_tier[tier]: 
			if s is PackedScene: 
				pool.append(s) 
	return pool

func build_upgrade_pool(level: int) -> void:
	remaining_upgrade_pool.clear()
	remaining_upgrade_pool = get_upgrade_scene_pool(level)
	remaining_upgrade_pool.shuffle()

func pick_unique_upgrade(level: int) -> PackedScene:
	if remaining_upgrade_pool.is_empty():
		# Refill once all unique options are used
		build_upgrade_pool(level)

	if remaining_upgrade_pool.is_empty():
		return null

	return remaining_upgrade_pool.pop_back()


func spawn_parts(level: int) -> void:
	if remaining_upgrade_pool.is_empty():
		build_upgrade_pool(level)

	var free_markers: Array[Marker2D] = []
	for marker in part_spawn_markers:
		if marker.get_child_count() == 0:
			free_markers.append(marker)

	if free_markers.is_empty():
		return

	free_markers.shuffle()

	var spawn_count : int = min(6, free_markers.size())

	for i in range(spawn_count):
		var scene := pick_unique_upgrade(level)
		if scene == null:
			break
		var part := scene.instantiate() as Anatomy
		var marker := free_markers[i]

		marker.add_child(part)
		part.global_position = marker.global_position + Vector2(
			randf_range(-3, 3),
			randf_range(-3, 3)
		)
		part.rotation = marker.global_rotation + randf_range(-5, 5)

		part.state = Anatomy.PartState.OutOfBody
		upgrade_parts.append(part)
		
		if part.body_owner == null:
			part.state = Anatomy.PartState.OutOfBody
			upgrade_parts.append(part)


func is_marker_occupied(marker: Marker2D, radius := 2.0) -> bool:
	for part in upgrade_parts:
		if not is_instance_valid(part):
			continue
		if part.global_position.distance_to(marker.global_position) <= radius:
			return true
	return false

func connect_parts_interact_signal() -> void:
	if upgrade_parts.is_empty():
		return
	for part in upgrade_parts:
		if is_instance_valid(part):
			if not part.anatomy_clicked.is_connected(player._on_self_anatomy_clicked):
				part.anatomy_clicked.connect(player._on_self_anatomy_clicked)

@onready var part_info_panel: MarginContainer = $CanvasLayer/PartInfoPanel
@onready var label_part_name: Label = %LabelPartName
@onready var label_part_state: Label = %LabelPartState
@onready var label_part_hp: Label = %LabelPartHP
@onready var bar_part_hp: TextureProgressBar = %BarPartHP
@onready var stat_labels: Array[Label] = [%LabelPartStat1, %LabelPartStat2, %LabelPartStat3, %LabelPartStat4]

func show_part_info(_name: String, _state: String, _hp: float, _max_hp: float, _stats: Array[String]) -> void:
	if not part_info_panel.visible:
		return
		
	for label in stat_labels:
		label.text = ""
	
	match _stats.size():
		1: label_part_name.modulate = Color.WHITE
		2: label_part_name.modulate = Color.DEEP_SKY_BLUE * 1.5
		3: label_part_name.modulate = Color.PURPLE * 1.5
		4: label_part_name.modulate = Color.GOLD * 1.5
		
	label_part_name.text = _name
	label_part_state.text = _state
	label_part_hp.text = "max hp " + str(int(_max_hp))
	bar_part_hp.max_value = _max_hp
	bar_part_hp.value = _hp

	for i in min(_stats.size(), stat_labels.size()):
		stat_labels[i].text = _stats[i]

func hide_part_info() -> void:
	for label in stat_labels:
		label.text = ""
	label_part_name.modulate = Color.WHITE
	label_part_name.text = ""
	label_part_state.text = ""
	label_part_hp.text =  ""
	bar_part_hp.max_value = 1
	bar_part_hp.value = 0
	for label in stat_labels:
		label.text = ""
