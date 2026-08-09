extends Node2D

@onready var player = $AnimationPlayer
@onready var label = $Label

var text: String
var text_color: Color = Color(1.0, 0.313726, 0.160784, 1.0)
var font_size: int = 30

func _ready():
	var settings := label.label_settings.duplicate() as LabelSettings
	settings.font_color = text_color
	settings.font_size = font_size
	label.label_settings = settings
	label.text = text
	player.play("fade")		

func _on_animation_player_animation_finished(anim_name):
	queue_free()
