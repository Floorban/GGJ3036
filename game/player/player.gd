class_name Player extends Character

var selected_target: Anatomy

var all_anatomy_in_scene: Array[Anatomy]
var enemy_anatomy: Array[Anatomy]

func _ready() -> void:
	get_anatomy_references()

func choose_target() -> Anatomy:
	if selected_target and selected_target.state != Anatomy.PartState.DESTROYED:
		return selected_target
	return super.choose_target()

func get_anatomy_references() -> void:
	for anatomy in get_tree().get_nodes_in_group("anatomy"):
		all_anatomy_in_scene.append(anatomy)
		if anatomy.get_parent() != self:
			enemy_anatomy.append(anatomy)
			anatomy.anatomy_clicked.connect(_on_enemy_anatomy_clicked)

func _on_enemy_anatomy_clicked(anatomy: Anatomy) -> void:
	if anatomy.state == Anatomy.PartState.DESTROYED:
		return

	selected_target = anatomy
	_highlight_target(anatomy)

func _highlight_target(anatomy: Anatomy) -> void:
	for part in enemy_anatomy:
		part.sprite.modulate = Color.WHITE

	anatomy.sprite.modulate = Color.RED
