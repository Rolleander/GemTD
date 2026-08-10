extends Combination

class_name GemCombine

var combination: SpecialGem

func _init(gems: Array[Gem], combination: SpecialGem):
	self.gems = gems
	self.combination = combination

func combine(target: Gem) -> Gem:
	var material = []
	gems.erase(target)
	var gems_by_exp := gems.duplicate()
	gems_by_exp.sort_custom(func(a: Gem, b: Gem) -> bool: return a.exp > b.exp)
	var other_gems = combination.recipe.duplicate()
	for r in other_gems:
		if r.quality == target.quality && r.type == target.type:
			other_gems.erase(r)
			break
	for r in other_gems:
		for gem in gems_by_exp:
			if gem.quality == r.quality && gem.type == r.type && gem.special_combination == null && !material.has(gem):
				material.append(gem)
				break
	var exp = 0
	for g in material:
		exp += g.exp
		target.kills += g.kills
		g.make_rock()
	#init special gem and give exp
	target.gem_name = combination.name
	var special_scene := combination.scene.instantiate() as SpecialGemScene
	if special_scene == null:
		push_error("Special gem scene must extend SpecialGemScene.")
		return target
	special_scene.install(target)
	LevelUp.gain_exp(target, exp, false)
	return target
