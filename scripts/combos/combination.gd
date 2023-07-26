extends Node

class_name Combination

var gems : Array[Gem]

func fuse(target : Gem):
	pass

func clear_material():
	for gem in gems:
		gem.queue_free()
