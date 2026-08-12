extends Resource

class_name SpecialGem

const Type = preload("res://scripts/gem_types.gd").GemType

@export var recipe: Array[BasicGemId]
@export var name: String
@export var description: String
@export var type: Type
@export var tiers: Array[SpecialGemTier] = []
@export var scene: PackedScene
