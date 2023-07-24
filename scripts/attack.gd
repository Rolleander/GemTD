extends Node2D

class_name Attack

@export var damage : float
@export var attack_range : float
@export var attack_delay : float = 1
@export var description : String 
@export var targets_air : bool = true
@export var targets_ground : bool = true

var gem : Gem

func init():
	if gem.quality ==null || gem.type == null:
		return
	var type_info = Globals.get_gem_info(gem.type)
	var quality_info = Globals.get_quality_info(gem.quality)
	damage = round(damage* quality_info.damage_scale)
	attack_range *= quality_info.range_scale
	attack_delay *= quality_info.attack_delay_scale
