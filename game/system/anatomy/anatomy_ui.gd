class_name AnatomyUI extends Control

@onready var panel: Panel = $Panel

@onready var label_name: Label = %LabelName
@onready var hp_bar: ProgressBar = %HpBar
@onready var label_state: Label = %LabelState
@onready var label_block: Label = %LabelBlock
@onready var label_effect: Label = %LabelEffect

func set_hp_bar(hp: float, max_hp: float) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = hp

func set_stats_ui(id: String, state: String, block_amount: int, effect: String) -> void:
	label_name.text = id
	label_state.text = state
	label_block.text = "block " + str(block_amount) + " DMG"
	label_effect.text = effect

func toggle_panel(turned_on: bool) -> void:
	visible = turned_on
