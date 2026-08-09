extends Combination

class_name GemCombine

var combination: SpecialGem

func _init(gems: Array[Gem], combination: SpecialGem):
	self.gems = gems
	self.combination = combination

func combine(target: Gem) -> Gem:
	var material = []
	gems.erase(target)
	for r in combination.recipe:
		for gem in gems:
			if gem.quality == r.quality && gem.type == r.type && gem.special_combination == null && !material.has(gem):
				material.append(gem)
				break
	var exp = 0.0
	for g in material:
		exp += g.exp
		if g != target:
			g.make_rock()
	#init special gem and give exp		
	target.special_combination = combination
	target.set_attack(combination.scene.instantiate())
	LevelUp.gain_exp(target, exp, false)
	return target
