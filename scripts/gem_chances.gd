extends Node

class_name GemChances

const MAX_LEVEL = 7
const Quality = preload("res://scripts/gem_quality.gd").GemQuality
const Type = preload("res://scripts/gem_types.gd").GemType
var level = 0

func get_random_quality():
	var chance = Globals.get_roll_chances(level).get_as_dict()
	var number = randi_range(1, 100)
	for Quality in chance.keys():
		if number <= chance[Quality]:
			return Quality			
		number -= chance[Quality]

func get_random_type():
	var size = Type.values().size()
	return Type.values()[randi_range(0,size-1)]

func get_upgrade_cost():
	if level == MAX_LEVEL:
		return 0
	return Globals.get_roll_chances(level+1).upgrade_cost

func inc_level():
	if level < MAX_LEVEL:
		level+=1
