extends Combination

class_name GemFusion

var fusion_size: int
var fusion_name: String

func _init(gems: Array[Gem], fusion_size: int):
	self.gems = gems
	self.fusion_size = fusion_size
	var target_quality = gems[0].quality + fusion_size / 2
	var type_info = Globals.get_gem_info(gems[0].type)
	var quality_info = Globals.get_quality_info(target_quality)
	if quality_info.label != null && !quality_info.label.is_empty():
		fusion_name += quality_info.label + " "
	fusion_name += type_info.label

func fuse(target: Gem) -> Gem:
	var quality = target.quality
	quality += fusion_size / 2
	target.init_basic_gem(target.type, quality)
	gems.erase(target)
	for g in gems:
		g.make_rock()
	return target
