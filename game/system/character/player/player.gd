class_name Player extends Character

var selected_target: Anatomy

func get_anatomy_references() -> void:
	super.get_anatomy_references()
	for a in anatomy_parts:
		a.anatomy_clicked.connect(_on_self_anatomy_clicked)
	for a in opponent_anatomy:
		a.anatomy_clicked.connect(_on_enemy_anatomy_clicked)

func start_round() -> void:
	super.start_round()
	if selected_target:
		selected_target.is_targeted = true
		selected_target._highlight_target()

func choose_target() -> Anatomy:
	if selected_target and selected_target.state != Anatomy.PartState.DESTROYED:
		return selected_target
	return null

func _on_action_ready() -> void:
	if not can_control:
		selected_target.is_targeted = false
		selected_target._unhighlight_target()
		return
	super._on_action_ready()
	if selected_target and can_action and not blocking_part:
		if selected_target.state != Anatomy.PartState.DESTROYED:
			_perform_attack(selected_target)
		else:
			selected_target.is_targeted = false
			selected_target._unhighlight_target()
			selected_target = null
			arm.rest_pos()

func _on_block_finished() -> void:
	super._on_block_finished()
	if selected_target:
		selected_target._unhighlight_target()
	selected_target = null
	if blocking_part:
		blocking_part.is_blocking = false
	blocking_part = null
	arm.interrupt(func(): 
		if can_control:
			combat_component.reset_attack_timer(action_cooldown)
			combat_component.start()
	)

func _on_self_anatomy_clicked(anatomy: Anatomy) -> void:
	if arm.movable_by_mouse and anatomy.state == Anatomy.PartState.FUCKED:
		if arm.dragging_obj is Anatomy:
			(arm.dragging_obj as Anatomy).is_being_dragged = false
		arm.dragging_obj = anatomy
		arm.dragging_obj.is_being_dragged = true
		arm.z_index = -2
		return

	if arm.is_punching or not can_control:
		return
	if selected_target != anatomy:
		if selected_target:
			if selected_target in opponent_anatomy:
				selected_target.is_targeted = false
				selected_target._unhighlight_target()
		selected_target = anatomy
		_perform_block(anatomy)
	else:
		selected_target = null
		if blocking_part:
			blocking_part.is_blocking = false
		blocking_part = null
		anatomy._unhighlight_target()
		arm.rest_pos()

func _on_enemy_anatomy_clicked(anatomy: Anatomy) -> void:
	if anatomy.state == Anatomy.PartState.DESTROYED or not can_control:
		return
	if selected_target != anatomy:
		if arm.is_blocking and blocking_part:
			blocking_part.is_blocking = false
			blocking_part = null
			arm.rest_pos()
		anatomy.is_targeted = true
		anatomy._highlight_target()
		if selected_target:
			if selected_target in opponent_anatomy:
				selected_target.is_targeted = false
				selected_target._unhighlight_target()
		selected_target = anatomy
		if can_action:
			_perform_attack(selected_target)
	#else:
		#selected_target = null
		#anatomy.is_targeted = false
		#anatomy._unhighlight_target()
