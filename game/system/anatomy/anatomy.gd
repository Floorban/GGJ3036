class_name Anatomy extends Node2D

@export var stat_modifiers := {
	Stats.StatType.MAX_HP: 0.0,
	Stats.StatType.COOLDOWN: -0.1,
	Stats.StatType.DAMAGE: 0.1,
	Stats.StatType.ATTACK_SPEED: 0.1,
	Stats.StatType.CRIT_CHANCE: 0.0,
	Stats.StatType.CRIT_DAMAGE: 0.0
}

func get_stat_modifiers() -> Dictionary:
	if state == PartState.DESTROYED:
		return {}
		
	var mods := stat_modifiers.duplicate(true)
	if state == PartState.FUCKED:
		for stat in mods:
			mods[stat] *= 0.5

	return mods

func get_stat_strings() -> Array[String]:
	var lines: Array[String] = []
	for stat in stat_modifiers:
		var val = stat_modifiers[stat]
		if val == 0:
			continue

		var sign := "+" if val > 0 else ""
		lines.append("%s %s%s" % [
			Stats.stat_to_string(stat),
			sign,
			val * 10
		])
	return lines

enum AnatomyType {Eye, Ear, Nose, Mouth}
@export var anatomy_type: AnatomyType 

signal anatomy_clicked(anatomy: Anatomy)
signal anatomy_hit(damage: float)
signal anatomy_fucked()

enum PartState { HEALTHY, FUCKED, DESTROYED, OutOfBody }
@export var state: PartState = PartState.HEALTHY

var body_owner : Character

@export var max_hp : float
@export var current_hp : float
@export var block_amount : float

@onready var sprite: Sprite2D = $Sprite
@onready var mouse_detect_area: Area2D = $MouseDetectArea

var is_targeted := false
var is_blocking := false
var is_hovering := false
var is_being_dragged := false

var current_color: Color = Color.WHITE

var outline_mat: ShaderMaterial

@export var fix_areas : Array[FixArea]

func _ready() -> void:
	current_hp = max_hp
	if not mouse_detect_area.mouse_entered.is_connected(_hover_over_part):
		mouse_detect_area.mouse_entered.connect(_hover_over_part)
	if not mouse_detect_area.mouse_exited.is_connected(_unhover_part):
		mouse_detect_area.mouse_exited.connect(_unhover_part)
	if not mouse_detect_area.input_event.is_connected(_on_input_event):
		mouse_detect_area.input_event.connect(_on_input_event)
	outline_mat = sprite.material as ShaderMaterial
	outline_mat.set_shader_parameter("alphaThreshold", 0.0)
	_unhighlight_target()
	for a : FixArea in get_tree().get_nodes_in_group("fix_area"):
		if a.anatomy_type == anatomy_type: fix_areas.append(a)
	for i in 8:
		await get_tree().physics_frame
	hovering.connect(Stats.rest_room.show_part_info)
	unhover.connect(Stats.rest_room.hide_part_info)

func init_part(body: Character) -> void:
	body_owner = body
	#anatomy_ui.toggle_panel(false)

func recover_part() -> void:
	current_hp = max_hp
	body_owner.health += current_hp
	state = PartState.HEALTHY
	#anatomy_ui.set_hp_bar(current_hp, max_hp)
	#anatomy_ui.set_stats_ui(name, PartState.keys()[state], int(block_amount), "nothing now")
	current_color = Color.WHITE
	sprite.modulate = current_color

func pickup_part() -> void:
	if is_being_dragged:
		return
	is_being_dragged = true
	_unhover_part()
	if current_hp > 0:
		for area in fix_areas:
			area.highlight_zone()

func drop_part() -> void:
	if not is_being_dragged:
		return
	is_being_dragged = false
	for area in fix_areas:
		area.unhighlight_zone()

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if (body_owner and not body_owner.rest_mode) and (state == PartState.DESTROYED or is_being_dragged):
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			anatomy_clicked.emit(self)
			get_viewport().set_input_as_handled()

signal hovering(_name: String, _state: String, _hp: float, _max_hp: float, _stats: Array[String])
signal unhover()

func _hover_over_part() -> void:
	if (body_owner and not body_owner.rest_mode) and  (state == PartState.DESTROYED or is_being_dragged):
		return
	if (state == PartState.HEALTHY and not body_owner.can_control and not body_owner.rest_mode):
		return
	if (body_owner and body_owner.rest_mode and state == PartState.HEALTHY):
		hovering.emit(AnatomyType.keys()[anatomy_type], PartState.keys()[state], current_hp, max_hp, get_stat_strings())
		return
	if is_being_dragged:
		return
	#anatomy_ui.toggle_panel(true)
	#if not is_targeted:
	outline_mat.set_shader_parameter("alphaThreshold", 0.1)
	sprite.use_parent_material = false
	is_hovering = true
	hovering.emit(AnatomyType.keys()[anatomy_type], PartState.keys()[state], current_hp, max_hp, get_stat_strings())

func _unhover_part() -> void:
	#anatomy_ui.toggle_panel(false)

	outline_mat.set_shader_parameter("alphaThreshold", 0.0)
	sprite.use_parent_material = true
	is_hovering = false
	#unhover.emit()


func _highlight_target() -> void:
	if is_part_dead():
		return

	if is_targeted:
		sprite.use_parent_material = true
		sprite.modulate = Color.RED * 2.0

func _unhighlight_target() -> void:
	if not is_targeted:
		sprite.modulate = current_color
		sprite.use_parent_material = true

# refactor later when heal
func set_hp(changed_amount: float, crit: bool = false) -> void:
	current_hp -= changed_amount
	#anatomy_ui.set_hp_bar(current_hp, max_hp)
	#anatomy_ui.set_stats_ui(name, PartState.keys()[state], int(block_amount), "nothing now")
	if current_hp <= max_hp / 2 and state != PartState.DESTROYED:
		state = PartState.FUCKED
		move_part()
		current_color = Color.CHOCOLATE
		anatomy_fucked.emit()
		if not is_targeted:
			sprite.modulate = current_color
	if current_hp <= 0 and state != PartState.DESTROYED:
		part_dead()
	
	if crit: 
		audio.play(body_owner.sfx_crit)
	else: 
		audio.play(body_owner.sfx_hit, global_transform, "Intensity", changed_amount / max_hp)
	PopupPrompt.display_prompt("!", changed_amount, global_position, 2.0)

func part_dead() -> void:
	state = PartState.DESTROYED
	current_color = Color.WEB_PURPLE
	sprite.modulate = current_color
	move_part()
	anatomy_fucked.emit()
	#audio.play(body_owner.sfx_hurt)

func move_part() -> void:
	rotation += randf_range(-0.8, 0.8)
	position += Vector2(randf_range(-2, 2), randf_range(-2, 2))

func is_part_dead() -> bool:
	return state == PartState.DESTROYED
