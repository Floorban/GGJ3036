extends Node

var rest_room : RestRoom

enum StatType {
	MAX_HP,
	DAMAGE,
	ATTACK_SPEED,
	CRIT_CHANCE,
	COOLDOWN
}

static func stat_to_string(stat: StatType) -> String:
	match stat:
		StatType.MAX_HP: return "Max HP"
		StatType.DAMAGE: return "Damage"
		StatType.ATTACK_SPEED: return "Attack Speed"
		StatType.CRIT_CHANCE: return "Crit Chance"
		StatType.COOLDOWN: return "Cooldown"
	return "? ? ?"
