extends Resource
class_name Tooltip

@export var icon: Texture2D
@export var text: String
@export_enum("WHITE", "DARK_RED") var color: String = "WHITE"

@export_multiline var description: String
