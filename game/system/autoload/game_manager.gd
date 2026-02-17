extends Node2D

var dragging_part: Anatomy = null
var hovered_part: Anatomy = null

func _process(_delta: float) -> void:
	update_hover()
	if Input.is_action_just_pressed("left_click"):
		if hovered_part:
			hovered_part.click_part()

func update_hover():
	var space_state = get_viewport().get_world_2d().direct_space_state
	var mouse_pos = get_global_mouse_position()

	var query = PhysicsPointQueryParameters2D.new()
	query.collision_mask = 1 << 0
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var result = space_state.intersect_point(query)

	var new_hover: Anatomy = null

	for hit in result:
		var collider = hit.collider
		if collider is Area2D:
			var parent = collider.get_parent()
			if parent is Anatomy:
				new_hover = parent
				break
	if new_hover != hovered_part:

		if hovered_part:
			hovered_part._unhover_part()

		hovered_part = new_hover

		if hovered_part:
			hovered_part._hover_over_part()

var main_menu : Menu


func return_to_main_menu() -> void:
	if main_menu == null:
		return
	main_menu.end()
