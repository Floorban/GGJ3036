class_name Anatomy extends Node2D

signal anatomy_clicked(anatomy: Anatomy)
signal anatomy_hit(damage: float)

enum PartState { HEALTHY, DESTROYED }
var state: PartState = PartState.HEALTHY

@export var max_hp : float
@export var current_hp : float
@export var block_amount : float

@onready var sprite: Sprite2D = $Sprite
@onready var original_color: Color = sprite.modulate
@onready var mouse_detect_area: Area2D = $MouseDetectArea
@onready var anatomy_ui: AnatomyUI = $AnatomyUI

var is_targeted := false
var is_blocking := false
var is_hovering := false

func init_part() -> void:
	current_hp = max_hp
	mouse_detect_area.mouse_entered.connect(_hover_over_part)
	mouse_detect_area.mouse_exited.connect(_unhover_part)
	mouse_detect_area.input_event.connect(_on_input_event)
	anatomy_ui.set_hp_bar(current_hp, max_hp)
	anatomy_ui.set_stats_ui(name, PartState.keys()[state], int(block_amount), "nothing now")
	anatomy_ui.toggle_panel(false)

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if not is_hovering:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			anatomy_clicked.emit(self)


func _hover_over_part() -> void:
	anatomy_ui.toggle_panel(true)
	is_hovering = true

func _unhover_part() -> void:
	anatomy_ui.toggle_panel(false)
	is_hovering = false

func _highlight_target(block_target := false) -> void:
	if is_part_dead():
		#sprite.modulate = Color.CHOCOLATE
		return

	if block_target:
		if is_blocking:
			sprite.modulate = Color.SKY_BLUE
	elif is_targeted:
		sprite.modulate = Color.RED

func _unhighlight_target() -> void:
	if is_part_dead():
		return
	sprite.modulate = original_color

# refactor later when heal
func set_hp(changed_amount: float) -> void:
	current_hp -= changed_amount
	anatomy_ui.set_hp_bar(current_hp, max_hp)
	if current_hp <= 0 and state != PartState.DESTROYED:
		part_dead()
	#elif current_hp <= max_hp * 0.4:
		#state = PartState.OUT_OF_PLACE

func part_dead() -> void:
	state = PartState.DESTROYED
	sprite.rotation += randf_range(-1, 1)
	sprite.position += Vector2(randf_range(-15, 15), randf_range(-5,20))
	sprite.modulate = Color.CHOCOLATE

func is_part_dead() -> bool:
	return state == PartState.DESTROYED
