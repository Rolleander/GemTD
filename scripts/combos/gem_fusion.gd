extends Combination

class_name GemFusion

func _init(gems : Array[Gem]):
	self.gems = gems

func fuse(target : Gem):
	var quality = target.quality 
	quality += gems.size() / 2
	var gem = preload("res://scenes/gem.tscn").instantiate()
	gem.position = target
	target.get_parent().add_child(gem)
	gem.init_basic_gem(target.type, quality)
	gem.activate(true)	
	clear_material()
	
