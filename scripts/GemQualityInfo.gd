extends Resource

class_name GemQualityInfo

const Quality = preload("res://scripts/gem_quality.gd").GemQuality

@export var label : String
@export var damage_scale : float = 1
@export var range_scale : float = 1
@export var attack_delay_scale : float = 1
@export var quality : Quality
@export var scene : PackedScene 
