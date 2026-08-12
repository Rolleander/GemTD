extends Node

const MAX_LEVEL = 15
const SHARE_LEVEL = 12
const SHARE_FACTOR = 0.5
const SHARE_RANGE = 3.5
const EXP_TEXT_COLOR := Color(0.25, 0.68, 1.0, 1.0)
const EXP_TEXT_SIZE := 28
const LEVEL_UP_TEXT_SIZE := 35

func gain_exp_from(gem: Gem, enemy: Enemy):
	gain_exp(gem, 1.0)

func gain_exp(gem: Gem, exp: float, share = true):
	if exp <= 0:
		return
	if share && gem.level >= SHARE_LEVEL:
		for neighbour in BuffUtils.list_gems_in_range(gem, SHARE_RANGE):
			_receive_shared_exp(neighbour, exp * SHARE_FACTOR)
		return
	if gem.level >= MAX_LEVEL:
		return
	_gain_exp(gem, exp)

func level_up(gem: Gem):
	if gem.level >= MAX_LEVEL:
		return
	gem.level += 1
	if gem.level < MAX_LEVEL:
		gem.levelup_exp = get_levelup_exp(gem.level + 1)
	gem.update_level_visual()
	BuffUtils.update_tower_buffs()
		
func get_levelup_exp(level: int):
	var exp = level * 10
	if level == 13:
		exp = 140
	if level == 14:
		exp = 170
	if level == 15:
		exp = 200
	return exp

func _receive_shared_exp(gem: Gem, exp: float):
	if gem.level >= SHARE_LEVEL:
		return
	_gain_exp(gem, exp, true)

func _gain_exp(gem: Gem, exp: float, shared = false):
	gem.exp += exp
	Events.overlay_text(gem.position, "+%sXP" % _format_exp(exp), EXP_TEXT_COLOR,
	 (EXP_TEXT_SIZE - 6) if shared else EXP_TEXT_SIZE)
	if gem.exp >= gem.levelup_exp:
		while gem.level < MAX_LEVEL && gem.exp >= gem.levelup_exp:
			level_up(gem)
		Events.overlay_text(gem.position + Vector2(0, -25.0), "LEVEL UP", EXP_TEXT_COLOR, LEVEL_UP_TEXT_SIZE)
	
func _format_exp(exp: float) -> String:
	return ("%.1f" % exp).trim_suffix(".0")
