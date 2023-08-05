extends Node

func check(gems : Array):
	var combos = []
	#check fusion
	var fusion = {}
	for gem in gems:
		if !gem.special_combination:
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
	print(combos)
	return combos

