class_name Player extends Character

var selected_target: Anatomy

@export var sfx_hit: String

func get_anatomy_references() -> void:
	super.get_anatomy_references()
	for a in anatomy_parts:
		a.anatomy_clicked.connect(_on_anatomy_clicked)
	for a in opponent_anatomy:
		a.anatomy_clicked.connect(_on_anatomy_clicked)

	#for anatomy in opponent_anatomy:
		#anatomy.anatomy_clicked.connect(_on_enemy_anatomy_clicked)

func choose_target() -> Anatomy:
	if selected_target and selected_target.state != Anatomy.PartState.DESTROYED:
		return selected_target
	return null

func _on_action_ready() -> void:
	super._on_action_ready()
	if selected_target and can_action and not blocking_part:
		_perform_attack(selected_target)

func _on_anatomy_clicked(anatomy: Anatomy) -> void:
	if anatomy in opponent_anatomy:
		_on_enemy_anatomy_clicked(anatomy)
	elif anatomy in anatomy_parts:
		_on_self_anatomy_clicked(anatomy)

func _on_self_anatomy_clicked(anatomy: Anatomy) -> void:
	if selected_target != anatomy:
		selected_target = anatomy
		_highlight_target(anatomy, true)
		_perform_block(anatomy)
	else:
		selected_target = null
		blocking_part = null
		_highlight_target(null)
		arm.rest_pos()

func _on_enemy_anatomy_clicked(anatomy: Anatomy) -> void:
	if anatomy.state == Anatomy.PartState.DESTROYED:
		return
	if selected_target != anatomy:
		if blocking_part:
			arm.rest_pos()
		selected_target = anatomy
		_highlight_target(anatomy)
		if can_action:
			_perform_attack(selected_target)
	else:
		selected_target = null
		blocking_part = null
		_highlight_target(null)
		


	
