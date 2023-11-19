extends Node

func check(gems : Array):
	#check fusion
	var combos = _check_fusions(gems)
	combos.append_array(check_combine_gems(gems))
	return combos

func _check_fusions(gems : Array):
	var combos = []
	var fusion = {}
	for gem in gems:
		if gem.special_combination == null:
			var key = str(gem.type)+str(gem.quality)
			if fusion.has(key):
				fusion[key][0].append(gem)
				fusion[key][1] +=1
			else:			
				fusion[key] = [[gem] as Array[Gem], 1]
	for f in fusion.keys():
		if fusion[f][1] >=2:
			combos.append(GemFusion.new(fusion[f][0], 2))
		if fusion[f][1] >=4:
			combos.append(GemFusion.new(fusion[f][0], 4))
	return combos
	
func check_combine_gems(gems : Array):
	var combos = []
	for special in Globals.get_special_gems():
		var matches= _get_recipe_matches(gems, special.recipe)
		if !matches.is_empty():
			combos.append(GemCombine.new(matches, special))
	return combos
	
func _get_recipe_matches(gems : Array, recipe : Array[BasicGemId]):
	var matches = 0
	var target_gems = [] as Array[Gem]
	for r in recipe:
		for gem in gems:
			if gem.quality == r.quality && gem.type == r.type && gem.special_combination == null:
				target_gems.append(gem)
				matches +=1
	if matches < recipe.size():
		target_gems.clear()
	return target_gems
	
