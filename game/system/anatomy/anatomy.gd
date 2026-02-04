class_name Anatomy extends Node2D

enum AnatomyType {Eye, Ear, Nose, Mouth}
@export var anatomy_type: AnatomyType 

signal anatomy_clicked(anatomy: Anatomy)
signal anatomy_hit(damage: float)

enum PartState { HEALTHY, FUCKED, DESTROYED }
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

var current_color: Color

var sfx_block: String = "event:/SFX/Combat/Block"
var sfx_crit: String = "event:/SFX/Combat/Crit"
var sfx_hit: String = "event:/SFX/Combat/Hit"

var outline_mat: ShaderMaterial

func _ready() -> void:
	outline_mat = sprite.material as ShaderMaterial
	outline_mat.set_shader_parameter("alphaThreshold", 0.0)
	_unhighlight_target()

func init_part(body: Character) -> void:
	body_owner = body
	recover_part()
	#anatomy_ui.toggle_panel(false)
	if not mouse_detect_area.mouse_entered.is_connected(_hover_over_part):
		mouse_detect_area.mouse_entered.connect(_hover_over_part)
	if not mouse_detect_area.mouse_exited.is_connected(_unhover_part):
		mouse_detect_area.mouse_exited.connect(_unhover_part)
	if not mouse_detect_area.input_event.is_connected(_on_input_event):
		mouse_detect_area.input_event.connect(_on_input_event)

func recover_part() -> void:
	current_hp = max_hp
	#state = PartState.HEALTHY
	#anatomy_ui.set_hp_bar(current_hp, max_hp)
	#anatomy_ui.set_stats_ui(name, PartState.keys()[state], int(block_amount), "nothing now")
	current_color = Color.WHITE
	sprite.modulate = current_color

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if state == PartState.DESTROYED or is_being_dragged:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			anatomy_clicked.emit(self)
			is_being_dragged = true
			get_viewport().set_input_as_handled()

func _hover_over_part() -> void:
	if state == PartState.DESTROYED:
		return
	#anatomy_ui.toggle_panel(true)
	#if not is_targeted:
	outline_mat.set_shader_parameter("alphaThreshold", 0.1)
	sprite.use_parent_material = false
	is_hovering = true

func _unhover_part() -> void:
	#anatomy_ui.toggle_panel(false)
	outline_mat.set_shader_parameter("alphaThreshold", 0.0)
	sprite.use_parent_material = true
	is_hovering = false

func _highlight_target(block_target := false) -> void:
	if is_part_dead():
		return

	if block_target:
		pass
		#if is_blocking:
			#sprite.modulate = Color.CADET_BLUE
	elif is_targeted:
		sprite.use_parent_material = true
		sprite.modulate = Color.RED * 2.0

func _unhighlight_target() -> void:
	if is_part_dead():
		return
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
		if not is_targeted:
			sprite.modulate = current_color
	if current_hp <= 0 and state != PartState.DESTROYED:
		part_dead()
	
	if crit: 
		audio.play(sfx_crit)
	else: 
		audio.play(sfx_hit, global_transform, "Intensity", changed_amount / max_hp)
	PopupPrompt.display_prompt("!", changed_amount, global_position, 2.0)

func part_dead() -> void:
	state = PartState.DESTROYED
	current_color = Color.WEB_PURPLE
	sprite.modulate = current_color
	move_part()

func move_part() -> void:
	rotation += randf_range(-0.8, 0.8)
	position += Vector2(randf_range(-2, 2), randf_range(-2, 2))

func is_part_dead() -> bool:
	return state == PartState.DESTROYED
