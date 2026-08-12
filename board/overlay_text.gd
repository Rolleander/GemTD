extends Node2D

@onready var player = $AnimationPlayer
@onready var label = $Label

var text: String
var text_color: Color = Color(1.0, 0.313726, 0.160784, 1.0)
var font_size: int = 30
var delay = 0.0
var world_billboard = false
var screen_billboard = false
var world_position = Vector2.ZERO
var board: Board

func _ready():
	if world_billboard:
		scale.y *= Globals.BILLBOARD_Y_SCALE
	var settings = label.label_settings.duplicate() as LabelSettings
	settings.font_color = text_color
	settings.font_size = font_size
	label.label_settings = settings
	label.text = text
	label.reset_size()
	label.position.x = -label.size.x * label.scale.x * 0.5
	if delay > 0:
		Events.delayed(func(): player.play("fade"), delay)
		return
	player.play("fade")

func _process(_delta):
	if screen_billboard:
		sync_billboard()

func sync_billboard():
	if !screen_billboard || !is_instance_valid(board):
		return
	board.update_billboard(self, world_position)
	# Gem and enemy billboards use their screen Y for depth sorting, so world
	# feedback needs an explicit foreground depth.
	z_index = 4090

func _on_animation_player_animation_finished(anim_name):
	queue_free()
