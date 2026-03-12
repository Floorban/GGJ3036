class_name RestRoom extends Node2D

signal ready_to_fight()

@onready var background: Sprite2D = $Background
@onready var ready_button: TextureButton = %ReadyButton

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var upgrades: Node2D = %Upgrades
@export var upgrade_scenes_by_tier: Dictionary = {
	1: [],
	2: [],
	3: [],
	4: [],
	5: []
}

@export var slot_machine : SlotMachine

static var attaching: bool = false
static var attached_index: float
var sfx_attach: String = "event:/SFX/Surgery/Attach"

func get_allowed_tiers(level: int) -> Array[int]:
	if level < 1:
		return [1, 2]
	elif level < 3:
		return [3, 4, 5]
	elif level < 5:
		return [4, 5, 6]
	elif level < 7:
		return [5, 6, 7]
	elif level < 9:
		return [6, 7, 8]
	else:
		return [7, 8]

@export var upgrade_parts : Array[Anatomy]
@onready var part_spawn_markers: Array[Marker2D] = [%SpawnMarker1, %SpawnMarker2, %SpawnMarker3, %SpawnMarker4, %SpawnMarker5, %SpawnMarker6, %SpawnMarker7, %SpawnMarker8, %SpawnMarker9, %SpawnMarker10, %SpawnMarker11, %SpawnMarker12]

func _ready() -> void:
	GameManager.rest_room = self
	ready_button.pressed.connect(leave_rest_room)
	mc_info_panel.visible = false
	part_info_panel.visible = false
	background.visible = false
	ready_button.visible = false
	ready_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player.rest_mode = false
	slot_machine.spawn_part.connect(_on_slot_machine_spawned_parts)


func _on_slot_machine_spawned_parts(new_part: Anatomy) -> void:
	upgrade_parts.append(new_part)
	connect_parts_interact_signal()


func enter_rest_room(current_level: int) -> void:
	slot_machine.reward_index = 0
	background.visible = true
	ready_button.mouse_filter = Control.MOUSE_FILTER_STOP
	audio.muffle(true)
	
	Tutorial.surgery_intro()

	for part in player.anatomy_parts:
		if part.state == Anatomy.PartState.DESTROYED:
			part.body_owner = null
	await  get_tree().create_timer(0.1).timeout
	player.rest_mode = true
	#spawn_parts(current_level - 2)
	connect_parts_interact_signal()
	#for p in background.get_children():
		#p.z_index = 10
	
	await get_tree().create_timer(1.0).timeout
	player.rebuild_stats()
	part_info_panel.visible = true
	mc_info_panel.visible = true
	ready_button.visible = true
	
	for part in player.anatomy_parts:
		if is_instance_valid(part):
			if part.body_owner == null or part.state == Anatomy.PartState.DESTROYED:
				player.anatomy_parts.erase(part)
				part.reparent(background)
				part.z_index = 500

func leave_rest_room() -> void:
	for i in range(player.anatomy_parts.size() - 1, -1, -1):
		var part = player.anatomy_parts[i]
		if is_instance_valid(part):
			if part.body_owner == null or part.state == Anatomy.PartState.DESTROYED:
				part.body_owner = null
				part.reparent(background)
				player.anatomy_parts.remove_at(i)
	if player.anatomy_parts.is_empty():
		Tutorial.start_with_no_parts()
		return
	part_info_panel.visible = false
	mc_info_panel.visible = false
	background.visible = false
	ready_button.visible = false
	ready_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	audio.muffle(false)

	clear_upgrade_parts()
	player.rest_mode = false
	await get_tree().create_timer(0.2).timeout
	ready_to_fight.emit()

func clear_upgrade_parts() -> void:
	for marker in part_spawn_markers:
		if not marker.get_children().is_empty():
			for c in marker.get_children():
				c.queue_free()
	#for part in upgrade_parts:
		#part.queue_free()
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

	var spawn_count : int = min(12, free_markers.size())

	for i in range(spawn_count):
		var scene := pick_unique_upgrade(level)
		if scene == null:
			break
		var part := scene.instantiate() as Anatomy
		part.disconnect.connect(func(): 
			part.body_owner = null
			part.reparent(background)
			part.z_index = 500
		)
		var marker := free_markers[i]

		marker.add_child(part)
		part.global_position = marker.global_position + Vector2(
			randf_range(-3, 3),
			randf_range(-3, 3)
		)
		part.rotation = marker.global_rotation + randf_range(-5, 5)
		part.z_index = 500
		part.state = Anatomy.PartState.OutOfBody
		upgrade_parts.append(part)
		
		if part.body_owner == null:
			part.state = Anatomy.PartState.OutOfBody
			upgrade_parts.append(part)

func connect_parts_interact_signal() -> void:
	if upgrade_parts.is_empty():
		return
	for part in upgrade_parts:
		if is_instance_valid(part):
			if not part.anatomy_clicked.is_connected(player._on_self_anatomy_clicked):
				part.anatomy_clicked.connect(player._on_self_anatomy_clicked)
				
@onready var mc_info_panel: MarginContainer = %MCInfoPanel


@onready var stat_label_hp: Label = %StatLabelHP
@onready var stat_label_cd: Label = %StatLabelCD
@onready var stat_label_dmg: Label = %StatLabelDmg
@onready var stat_label_speed: Label = %StatLabelSpeed
@onready var stat_label_crit_chance: Label = %StatLabelCritChance
@onready var stat_label_crit_dmg: Label = %StatLabelCritDMG
@onready var stat_label_stun_str: Label = %StatLabelStunSTR
@onready var stat_label_stun_resist: Label = %StatLabelStunResist


func update_mc_stat_info(stat_type: Stats.StatType, value: float) -> void:
	var formatted_value := "%.1f" % value
	match stat_type:
		Stats.StatType.MAX_HP:
			formatted_value = "%d" % value
			stat_label_hp.text = formatted_value
		Stats.StatType.COOLDOWN:
			formatted_value = "%.1f" % (value + 3.0)
			stat_label_cd.text = formatted_value + " s"
		Stats.StatType.DAMAGE:
			formatted_value = "%.1f" % (value + 1.0)
			stat_label_dmg.text = formatted_value
		Stats.StatType.ATTACK_SPEED:
			formatted_value = "%.2f" % (value + 0.05)
			stat_label_speed.text = formatted_value
		Stats.StatType.CRIT_CHANCE:
			stat_label_crit_chance.text = "%.1f%%" % (value * 100)
		Stats.StatType.CRIT_DAMAGE:
			formatted_value = "%.1f" % (value + 1.2)
			stat_label_crit_dmg.text = formatted_value + "x"
		Stats.StatType.STUN_STRENGTH:
			formatted_value = "%.1f" % (value + 1.0)
			stat_label_stun_str.text = formatted_value
		Stats.StatType.STUN_RESIST:
			formatted_value = "%.1f" % (value + 2.0)
			stat_label_stun_resist.text = formatted_value


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
	
	if _max_hp <= 3:
		label_part_name.modulate = Color.WHITE
	elif _max_hp <= 6:
		label_part_name.modulate = Color.LIME_GREEN * 1.5
	elif _max_hp <= 9:
		label_part_name.modulate = Color.DEEP_SKY_BLUE * 1.5
	elif _max_hp <= 12:
		label_part_name.modulate = Color.PURPLE * 1.5
	elif _max_hp <= 15:
		label_part_name.modulate = Color.RED * 1.5
	elif _max_hp <= 20:
		label_part_name.modulate = Color.GOLD * 1.5
		
		
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
