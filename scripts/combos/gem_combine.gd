extends Combination

class_name GemCombine

var combination : SpecialGem

func _init(gems :  Array[Gem], combination : SpecialGem):
	self.gems = gems
	self.combination = combination

func combine(target : Gem) -> Gem:
	var material = []
	gems.erase(target)
	for r in combination.recipe:
		if target.quality == r.quality && target.type == r.type && target.special_combination == null:
			continue
		for gem in gems:
			if gem.quality == r.quality && gem.type == r.type && gem.special_combination == null:
				material.append(gem)
				continue
	var exp = target.exp			
	for g in material:		
		exp += g.exp
		g.make_rock()
	#init special gem and give exp		
	target.special_combination = combination
	target.set_attack(combination.scene.instantiate())
	LevelUp.gain_exp(target, exp)	
	return target
