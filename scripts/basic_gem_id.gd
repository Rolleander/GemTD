extends Resource

class_name BasicGemId

const Quality = preload("res://scripts/gem_quality.gd").GemQuality
const Type = preload("res://scripts/gem_types.gd").GemType

@export var quality : Quality
@export var type : Type
