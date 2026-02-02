extends Node2D

signal battle_start
signal battle_end

@onready var game_ui: GameUI = %GameUI
@export var battle_duration := 60.0
var battle_time_left: float
@export var battle_ongoing : bool = false
	#set(value):
		#battle_ongoing = value
		#if battle_ongoing:
			#start_battle()

@export var player: Player
@export var enemy: Enemy

func _ready() -> void:
	init_combat_arena()
	if battle_ongoing:
		start_battle()

func init_combat_arena() -> void:
	battle_time_left = battle_duration
	player.opponent = enemy
	enemy.opponent = player
	player.init_character()
	enemy.init_character()

func start_battle() -> void:
	player.get_ready_to_battle()
	enemy.get_ready_to_battle()
	battle_start.emit()

func _process(delta: float) -> void:
	if battle_time_left <= 0:
		battle_time_left = 0
		battle_ongoing = false
		battle_end.emit()
	if battle_ongoing:
		battle_time_left -= delta
		game_ui.set_round_ui(battle_time_left)
	
