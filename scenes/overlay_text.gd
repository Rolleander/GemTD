extends Node2D

@onready var player = $AnimationPlayer
@onready var label = $Label

var text : String

func _ready():
	label.text  = text
	player.play("fade")		

func _on_animation_player_animation_finished(anim_name):
	queue_free()
