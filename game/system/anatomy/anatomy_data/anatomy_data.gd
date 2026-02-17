class_name AnatomyData extends Resource

@export var anatomy_type: Anatomy.AnatomyType
@export var anatomy_sprite: Texture2D
@export var anatomy_hp: int

@export var anatomy_stats := {
	Stats.StatType.MAX_HP: 0.0,
	Stats.StatType.COOLDOWN: -0.1,
	Stats.StatType.DAMAGE: 0.1,
	Stats.StatType.ATTACK_SPEED: 0.1,
	Stats.StatType.CRIT_CHANCE: 0.0,
	Stats.StatType.CRIT_DAMAGE: 0.0,
	Stats.StatType.STUN_STRENGTH: 1.0,
	Stats.StatType.STUN_RESIST: 1.0
}
