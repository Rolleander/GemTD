extends Node

var construction_fusions : Array[GemFusion] = []
var oneshot_combos : Array[GemCombine] = [] 
var board_combos : Array[GemCombine] = [] 

func check():
	construction_fusions.clear()
	oneshot_combos.clear()
	board_combos.clear()
	var building_gems = get_tree().get_nodes_in_group("building")
	construction_fusions.append_array(_check_fusions(building_gems))
	oneshot_combos.append_array(_check_combine_gems(building_gems))	
	var board_gems = Game.get_gems()
	board_combos.append_array(_check_combine_gems(board_gems))
	var combos = []
	combos.append_array(board_combos)
	combos.append_array(oneshot_combos)
	var gems = []
	gems.append_array(building_gems)
	gems.append_array(board_gems)
	_show_combos(combos, gems)

func _show_combos(combos, gems):
	for gem in gems:
		var c = _get_combo(combos, gem)
		if c!= null:
			gem.show_combine(c)	
		else:
			gem.hide_combine()
			
func _get_combo(combos, gem):
	for c in combos:
		if c.gems.has(gem):
			return c
	return null

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
	
func _check_combine_gems(gems : Array):
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
		var matched = false
		for gem in gems:
			if gem.quality == r.quality && gem.type == r.type && gem.special_combination == null:
				target_gems.append(gem)
				matched  = true
		if matched:
			matches +=1
	if matches < recipe.size():
		target_gems.clear()
	return target_gems

