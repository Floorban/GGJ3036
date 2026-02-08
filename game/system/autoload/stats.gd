extends Node

var rest_room : RestRoom

enum StatType {
	MAX_HP,
	COOLDOWN,
	DAMAGE,
	ATTACK_SPEED,
	CRIT_CHANCE,
	CRIT_DAMAGE,
	STUN_STRENGTH,
	STUN_RESIST
}

static func stat_to_string(stat: StatType) -> String:
	match stat:
		StatType.MAX_HP: return "Max HP "
		StatType.COOLDOWN: return "Cooldown "
		StatType.DAMAGE: return "Damage "
		StatType.ATTACK_SPEED: return "Punch Speed "
		StatType.CRIT_CHANCE: return "Crit Chance "
		StatType.CRIT_DAMAGE: return "Crit Damage "
		StatType.STUN_STRENGTH: return "Stun Duration "
		StatType.STUN_RESIST: return "Stun Resist "
	return "? ? ?"
