class_name GameUI extends Control

@onready var label_round_time_left: Label = %LabelRoundTimeLeft

func set_round_ui(time_left: float) -> void:
	label_round_time_left.text = str(int(time_left))
