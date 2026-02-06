class_name Anatomy extends Node2D

@export var stat_modifiers := {
	Stats.StatType.MAX_HP: 0.0,
	Stats.StatType.COOLDOWN: -0.1,
	Stats.StatType.DAMAGE: 0.1,
	Stats.StatType.ATTACK_SPEED: 0.1,
	Stats.StatType.CRIT_CHANCE: 0.0,
	Stats.StatType.CRIT_DAMAGE: 0.0
}

var sfx_select: String = "event:/SFX/UI/Select"

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

@export var og_pos : Vector2

func _ready() -> void:
	og_pos = global_position
	current_hp = max_hp
	if not mouse_detect_area.mouse_entered.is_connected(_hover_over_part):
		mouse_detect_area.mouse_entered.connect(_hover_over_part)
	if not mouse_detect_area.mouse_exited.is_connected(_unhover_part):
		mouse_detect_area.mouse_exited.connect(_unhover_part)
	if not mouse_detect_area.input_event.is_connected(_on_input_event):
		mouse_detect_area.input_event.connect(_on_input_event)
	if sprite: outline_mat = sprite.material as ShaderMaterial
	outline_mat.set_shader_parameter("alphaThreshold", 0.0)
	_unhighlight_target()
	for a : FixArea in get_tree().get_nodes_in_group("fix_area"):
		if a.anatomy_type == anatomy_type: fix_areas.append(a)
	for i in 8:
		await get_tree().physics_frame
	hovering.connect(Stats.rest_room.show_part_info)
	unhover.connect(Stats.rest_room.hide_part_info)

signal disconnect()

func _process(_delta: float) -> void:
	var dist := (global_position - og_pos).length()
	if state == PartState.HEALTHY and dist > 15.0 and not is_being_dragged:
		despawn_blood_line()
		#drop_part()
		state = PartState.FUCKED
		body_owner = null
		current_color = Color.CHOCOLATE
		anatomy_fucked.emit()
		if not is_targeted and sprite:
			sprite.modulate = current_color
		disconnect.emit()
	if is_being_dragged:
		update_blood_lines()

func update_blood_lines() -> void:
	for line in blood_lines:
		var start := line.get_point_position(0)
		var target := start + (global_position - og_pos)
		target += Vector2(
			randf_range(-5, 5),
			randf_range(-5, 5)
		)
		var current := line.get_point_position(1)
		line.set_point_position(1, current.lerp(target, 0.9))
		var stretch := (global_position - og_pos).length()
		line.width = lerp(30.0, 20.0, clamp(stretch / 10.0, 0, 1))

@export var blood_particle : PackedScene
@export var blood_line_textres: Array[Texture2D]
var blood_lines: Array[Line2D] = []

func despawn_blood_line() -> void:
	for line in blood_lines:
		_retract_blood_line(line, randf_range(0.2, 0.25))
	
	blood_lines.clear()
	if state == PartState.HEALTHY:
		var bp : GPUParticles2D = blood_particle.instantiate()
		bp.emitting = true
		add_child(bp)
		bp.global_position = og_pos

func _retract_blood_line(line: Line2D, duration := 0.2) -> void:
	if not is_instance_valid(line):
		return

	var start := line.get_point_position(1)
	var end := line.get_point_position(0)

	var tween := create_tween()
	#tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_trans(Tween.TRANS_BACK)
	#tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_method(
		func(v: Vector2):
			if is_instance_valid(line):
				line.set_point_position(1, v),
		start,
		end,
		duration
	)
	tween.parallel().tween_property(
		line,
		"width",
		0.0,
		duration
	)
	tween.tween_callback(func():
		if is_instance_valid(line):
			line.queue_free()
	)

func draw_blood_line() -> void:
	for line in blood_lines:
		line.queue_free()
	blood_lines.clear()

	var count := randi_range(3, 5)

	for i in count:
		var line := Line2D.new()
		line.width = randf_range(20.0, 30.0)
		line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
		line.texture = blood_line_textres.pick_random()

		var local_offset := Vector2(
			randf_range(-5, 5),
			randf_range(-5, 5)
		)

		add_child(line)

		line.points = [
			local_offset,
			local_offset + (global_position - og_pos)
		]

		blood_lines.append(line)

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
	if sprite: sprite.modulate = current_color

func pickup_part() -> void:
	if is_being_dragged:
		return
	og_pos = global_position
	if body_owner:
		draw_blood_line()
	is_being_dragged = true
	_unhover_part()
	audio.play(sfx_select)
	if current_hp > 0:
		for area in fix_areas:
			area.highlight_zone()

func drop_part() -> void:
	if not is_being_dragged:
		return
	for area in fix_areas:
		area.unhighlight_zone()
		
	if (state == PartState.OutOfBody) and not body_owner:
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(
			self,
			"global_position",
			og_pos,
			0.15
		)
		
		tween.tween_callback(func():
			global_position = og_pos
			is_being_dragged = false
		)
	else:
		is_being_dragged = false

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
	#if (state == PartState.HEALTHY and not body_owner.can_control and not body_owner.rest_mode):
		#return
	#if (body_owner and body_owner.rest_mode and state == PartState.HEALTHY):
		#hovering.emit(AnatomyType.keys()[anatomy_type], PartState.keys()[state], current_hp, max_hp, get_stat_strings())
		#return
	if is_being_dragged:
		return
	#anatomy_ui.toggle_panel(true)
	#if not is_targeted:
	outline_mat.set_shader_parameter("alphaThreshold", 0.1)
	if sprite: sprite.use_parent_material = false
	is_hovering = true
	hovering.emit(AnatomyType.keys()[anatomy_type], PartState.keys()[state], current_hp, max_hp, get_stat_strings())

func _unhover_part() -> void:
	#anatomy_ui.toggle_panel(false)

	outline_mat.set_shader_parameter("alphaThreshold", 0.0)
	if sprite: sprite.use_parent_material = true
	is_hovering = false
	#unhover.emit()


func _highlight_target() -> void:
	if is_part_dead():
		return

	if is_targeted and sprite:
		sprite.use_parent_material = true
		sprite.modulate = Color.RED * 2.0

func _unhighlight_target() -> void:
	if not is_targeted and sprite:
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
		if not is_targeted and sprite:
			sprite.modulate = current_color
	if current_hp <= 0 and state != PartState.DESTROYED:
		part_dead()
	
	if crit: 
		audio.play(body_owner.sfx_crit)
	else: 
		audio.play(body_owner.sfx_hit, global_transform, "Intensity", changed_amount / max_hp)
	if changed_amount > 0:
		PopupPrompt.display_prompt("!", int(changed_amount), global_position, 2.0)

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
