extends Node

const GRID_SIZE = 24
const TILE_SIZE = GRID_SIZE * 2

const Quality = preload("res://scripts/gem_quality.gd").GemQuality
const Type = preload("res://scripts/gem_types.gd").GemType
var loader = ResourcesLoader.new()

var gem_types: Array[GemTypeInfo] = []
var gem_qualities: Array[GemQualityInfo] = []
var roll_chances: Array[RollChances] = []
var special_gems: Array[SpecialGem] = []

func _ready() -> void:
	loader.load_resources_from_folder(gem_types, "res://resources/gem_types")
	loader.load_resources_from_folder(gem_qualities, "res://resources/gem_qualities")
	loader.load_resources_from_folder(roll_chances, "res://resources/roll_chances")
	loader.load_resources_from_folder(special_gems, "res://resources/special_gems")

func get_gem_info(type: Type) -> GemTypeInfo:
	for t in gem_types:
		if t.type == type:
			return t
	return null

func get_quality_info(quality: Quality) -> GemQualityInfo:
	for q in gem_qualities:
		if q.quality == quality:
			return q
	return null

func get_roll_chances(level) -> RollChances:
	for r in roll_chances:
		if r.level == level:
			return r
	return null

func get_special_gems() -> Array[SpecialGem]:
	return special_gems
