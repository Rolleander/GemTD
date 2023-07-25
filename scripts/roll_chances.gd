extends Resource

class_name RollChances

const Quality = preload("res://scripts/gem_quality.gd").GemQuality

@export var upgrade_cost = 0
@export var chipped = 100
@export var flawed = 0
@export var normal = 0
@export var flawless = 0
@export var perfect = 0

func get_as_dict():
	return {Quality.CHIPPED : chipped,
	Quality.FLAWED: flawed,
	Quality.NORMAL: normal,
	Quality.FLAWLESS: flawless,
	Quality.PERFECT: perfect}
	
