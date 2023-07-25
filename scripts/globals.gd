extends Node

const GRID_SIZE = 24
const TILE_SIZE = GRID_SIZE * 2

const GemTypeInfo = preload("res://scripts/GemTypeInfo.gd")
const GemQualityInfo = preload("res://scripts/GemQualityInfo.gd")
const Quality = preload("res://scripts/gem_quality.gd").GemQuality
const Type = preload("res://scripts/gem_types.gd").GemType
var setup = preload("res://resources/_setup.tres") 

func get_gem_info(type : Type) -> GemTypeInfo:
	return setup.gem_types[type] 

func get_quality_info(quality : Quality) -> GemQualityInfo:
	return setup.gem_qualities[quality] 

func get_roll_chances(level) ->RollChances:
	return setup.roll_chances[level]
