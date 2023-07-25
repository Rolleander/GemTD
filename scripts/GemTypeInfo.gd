extends Resource

class_name GemTypeInfo

const Type = preload("res://scripts/gem_types.gd").GemType

@export var label : String
@export var descirption : String
@export var color : Color
@export var attack : PackedScene 
@export var type : Type
