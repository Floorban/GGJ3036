extends Node2D

@export var player: Player
@export var enemy: Enemy

func _ready() -> void:
	init_combat_arena()

func init_combat_arena() -> void:
	player.opponent = enemy
	enemy.opponent = player
	player.init_character()
	enemy.init_character()

func _process(_delta: float) -> void:
	pass
