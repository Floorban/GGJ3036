class_name Character extends Node2D

var anatomy_parts: Array[Anatomy]
@onready var eye: Anatomy = %Eye
@onready var ear: Anatomy = %Ear
@onready var nose: Anatomy = %Nose
@onready var mouth: Anatomy = %Mouth

func init_character() -> void:
	anatomy_parts.append(eye)
	anatomy_parts.append(ear)
	anatomy_parts.append(nose)
	anatomy_parts.append(mouth)
	for part in anatomy_parts:
		part.init_part()
