class_name RetroScreen extends ColorRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func trans_to_break() -> void:
	animation_player.play("TransitionToRest")

func trans_to_combat() -> void:
	animation_player.play_backwards("TransitionToRest")
