extends Node

const Quality = preload("res://scripts/gem_quality.gd").GemQuality
const Type = preload("res://scripts/gem_types.gd").GemType
var level = 7

const chances = [
	#level 1
	{Quality.CHIPPED : 100,
	Quality.FLAWED: 0,
	Quality.NORMAL: 0,
	Quality.FLAWLESS: 0,
	Quality.PERFECT: 0},
		#level 2
	{Quality.CHIPPED : 70,
	Quality.FLAWED: 30,
	Quality.NORMAL: 0,
	Quality.FLAWLESS: 0,
	Quality.PERFECT: 0},
			#level 3
	{Quality.CHIPPED : 60,
	Quality.FLAWED: 30,
	Quality.NORMAL: 10,
	Quality.FLAWLESS: 0,
	Quality.PERFECT: 0},
			#level 4
	{Quality.CHIPPED : 40,
	Quality.FLAWED: 30,
	Quality.NORMAL: 20,
	Quality.FLAWLESS: 10,
	Quality.PERFECT: 0},
			#level 5
	{Quality.CHIPPED : 30,
	Quality.FLAWED: 30,
	Quality.NORMAL: 30,
	Quality.FLAWLESS: 10,
	Quality.PERFECT: 0},
	# level 6
	{Quality.CHIPPED : 20,
	Quality.FLAWED: 30,
	Quality.NORMAL: 30,
	Quality.FLAWLESS: 20,
	Quality.PERFECT: 0},
			#level 7
	{Quality.CHIPPED : 10,
	Quality.FLAWED: 30,
	Quality.NORMAL: 30,
	Quality.FLAWLESS: 30,
	Quality.PERFECT: 0},
			#level 8
	{Quality.CHIPPED : 0,
	Quality.FLAWED: 30,
	Quality.NORMAL: 30,
	Quality.FLAWLESS: 30,
	Quality.PERFECT: 10},
]

func get_random_quality():
	var chance = chances[level]
	var number = randi_range(1, 100)
	for Quality in chance.keys():
		if number <= chance[Quality]:
			return Quality			
		number -= chance[Quality]

func get_random_type():
	var size = Type.values().size()
	return Type.values()[randi_range(0,size-1)]

func get_level():
	return level
	
func inc_level():
	if level < 7:
		level+=1
