extends Combination

class_name GemFusion
var fusion_size : int

func _init(gems : Array[Gem], fusion_size : int):
	self.gems = gems
	self.fusion_size = fusion_size

func fuse(target : Gem) -> Gem:
	var quality = target.quality 
	quality += fusion_size / 2
	target.init_basic_gem(target.type, quality)
	gems.erase(target)
	for g in gems:		
		g.make_rock()
	return target
