extends Node

#towers gain 1xp per kill unti level 12, then they pass 0.5xp to each tower 
#within 3 range per kill (plus once for each kill until lv 12)

func gain_exp_from(gem : Gem, enemy : Enemy):
	gain_exp(gem, 1.0)

func gain_exp(gem : Gem, exp : float):
	if gem.level >= 15:
		return
	gem.exp += exp
	if gem.exp >= gem.levelup_exp:
		level_up(gem)

func level_up(gem : Gem):
	gem.level+=1
	if gem.level < 15:
		gem.levelup_exp = get_levelup_exp(gem.level+1)
	BuffUtils.update_tower_buffs()
		
func get_levelup_exp(level : int):
	var exp = level * 10	
	if level == 13:
		exp = 140
	if level == 14:
		exp = 170
	if level == 15:
		exp = 200
	return exp
