class_name FixArea extends Area2D

@onready var player: Player = get_tree().get_first_node_in_group("player")
var anatomy_type: Anatomy.AnatomyType
@export var my_anatomy: Anatomy
@onready var sprite: Sprite2D = $Sprite
var is_occupied := false
var is_hovering := false

func _ready() -> void:
	if my_anatomy: anatomy_type = my_anatomy.anatomy_type
	mouse_entered.connect(_hover_over_part)
	mouse_exited.connect(_unhover_part)
	input_event.connect(_on_input_event)

func receive_anatomy(anatomy: Anatomy) -> void:
	if is_occupied or anatomy.anatomy_type != anatomy_type:
		return
	anatomy.is_being_dragged = false
	anatomy.recover_part()
	anatomy.position = position
	anatomy.rotation = rotation
	player.arm.dragging_obj = null

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if player.arm.dragging_obj == null:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var target : Anatomy = player.arm.dragging_obj 
			player.arm.z_index = 0
			receive_anatomy(target)
			get_viewport().set_input_as_handled()

func _hover_over_part() -> void:
	if is_occupied:
		return
	is_hovering = true

func _unhover_part() -> void:
	is_hovering = false
