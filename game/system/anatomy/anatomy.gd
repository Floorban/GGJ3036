class_name Anatomy extends Node2D

signal anatomy_clicked(anatomy: Anatomy)
signal anatomy_hit(damage: float)

enum PartState { HEALTHY, DESTROYED }
var state: PartState = PartState.HEALTHY

var body_owner : Character

@export var max_hp : float
@export var current_hp : float
@export var block_amount : float

@onready var sprite: Sprite2D = $Sprite
@onready var mouse_detect_area: Area2D = $MouseDetectArea

var is_targeted := false
var is_blocking := false
var is_hovering := false

var current_color: Color

#AUDIO
var sfx_block: String = "event:/SFX/Combat/Block"
var sfx_crit: String = "event:/SFX/Combat/Crit"
var sfx_hit: String = "event:/SFX/Combat/Hit"

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
	#anatomy_ui.set_hp_bar(current_hp, max_hp)
	#anatomy_ui.set_stats_ui(name, PartState.keys()[state], int(block_amount), "nothing now")
	current_color = Color.WHITE
	sprite.modulate = current_color

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if state == PartState.DESTROYED:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			anatomy_clicked.emit(self)

func _hover_over_part() -> void:
	if state == PartState.DESTROYED:
		return
	#anatomy_ui.toggle_panel(true)
	is_hovering = true

func _unhover_part() -> void:
	#anatomy_ui.toggle_panel(false)
	is_hovering = false

func _highlight_target(block_target := false) -> void:
	if is_part_dead():
		#sprite.modulate = Color.CHOCOLATE
		return

	if block_target:
		pass
		#if is_blocking:
			#sprite.modulate = Color.CADET_BLUE
	elif is_targeted:
		sprite.modulate = Color.RED

func _unhighlight_target() -> void:
	if is_part_dead():
		return
	if not is_targeted:
		sprite.modulate = current_color

# refactor later when heal
func set_hp(changed_amount: float, crit: bool = false) -> void:
	current_hp -= changed_amount
	#anatomy_ui.set_hp_bar(current_hp, max_hp)
	#anatomy_ui.set_stats_ui(name, PartState.keys()[state], int(block_amount), "nothing now")
	if current_hp <= max_hp / 2 and state != PartState.DESTROYED:
		move_part()
		current_color = Color.CHOCOLATE
		if not is_targeted:
			sprite.modulate = current_color
	if current_hp <= 0 and state != PartState.DESTROYED:
		part_dead()
	
	if crit: audio.play(sfx_crit)
	else: audio.play(sfx_hit, global_transform, "Intensity", changed_amount / max_hp)
	#elif current_hp <= max_hp * 0.4:
		#state = PartState.OUT_OF_PLACE

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
