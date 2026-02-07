extends Node

var rest_room : RestRoom

enum StatType {
	MAX_HP,
	COOLDOWN,
	DAMAGE,
	ATTACK_SPEED,
	CRIT_CHANCE,
	CRIT_DAMAGE
}

static func stat_to_string(stat: StatType) -> String:
	match stat:
		StatType.MAX_HP: return "Max HP "
		StatType.COOLDOWN: return "Cooldown "
		StatType.DAMAGE: return "Damage "
		StatType.ATTACK_SPEED: return "Punch Speed "
		StatType.CRIT_CHANCE: return "Crit Chance "
		StatType.CRIT_DAMAGE: return "Crit Damage "
	return "? ? ?"
