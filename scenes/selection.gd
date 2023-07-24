extends Node2D

class_name Selection
@onready var area = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color.GREEN

func valid_place():
	return !area.has_overlapping_bodies()
	
