extends Node

const GRID_SIZE = 24
const TILE_SIZE = GRID_SIZE * 2

const GemTypeInfo = preload("res://scripts/GemTypeInfo.gd")
const GemQualityInfo = preload("res://scripts/GemQualityInfo.gd")
const Quality = preload("res://scripts/gem_quality.gd").GemQuality
const Type = preload("res://scripts/gem_types.gd").GemType
var _gems = preload("res://scenes/gems.tscn").instantiate()
var _gem_type_infos = _gems.find_child("GemTypesInfo").get_children()
var _gem_quality_infos = _gems.find_child("GemQualityInfo").get_children()

func get_gem_info(type : Type) -> GemTypeInfo:
	return _gem_type_infos[type] 

func get_quality_info(quality : Quality) -> GemQualityInfo:
	return _gem_quality_infos[quality] 
