class_name Player extends Character

var selected_target: Anatomy

func get_anatomy_references() -> void:
	super.get_anatomy_references()
	for anatomy in opponent_anatomy:
		anatomy.anatomy_clicked.connect(_on_enemy_anatomy_clicked)

func choose_target() -> Anatomy:
	if selected_target and selected_target.state != Anatomy.PartState.DESTROYED:
		return selected_target
	return null

func _on_attack_ready() -> void:
	super._on_attack_ready()
	if selected_target and can_attack:
		_perform_attack(selected_target)

func _on_enemy_anatomy_clicked(anatomy: Anatomy) -> void:
	if anatomy.state == Anatomy.PartState.DESTROYED:
		return
	
	if selected_target != anatomy:
		selected_target = anatomy
		_highlight_target(anatomy)
		if can_attack:
			_perform_attack(selected_target)
	else:
		selected_target = null
		_highlight_target(null)
