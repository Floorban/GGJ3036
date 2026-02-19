class_name MinionData extends Resource

@export var arm_scene: PackedScene
@export var arm_gesture: Vector2 = Vector2(-50, 100)

@export var face_variants: Array[PackedScene]
@export var ear_variants: Array[AnatomyData]
@export var eye_variants: Array[AnatomyData]
@export var mouth_variants: Array[AnatomyData]
@export var nose_variants: Array[AnatomyData]

@export var base_cooldown: float
@export var base_damage: float
@export var base_speed: float
@export var base_crit_chance: float
@export var base_crit_damage: float
@export var base_stun_strength: float
@export var base_stun_resist: float
@export var switch_chance: float
@export var min_switch_time: float

@export var sfx_die: String
@export var sfx_entry: String
@export var sfx_hurt: String
