extends Node2D

@export var player: Player
@export var enemy: Enemy

func _ready() -> void:
	init_combat_arena()
	start_battle()

func init_combat_arena() -> void:
	player.opponent = enemy
	enemy.opponent = player
	player.init_character()
	enemy.init_character()

func start_battle() -> void:
	player.get_ready_to_battle()
	enemy.get_ready_to_battle()

func _process(_delta: float) -> void:
	pass
