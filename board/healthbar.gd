extends Node2D

@export var health_percent : float = 1
@onready var bar = $bar

func _ready():
	z_index = 25

func _process(delta):
	if health_percent > 0.5 :
		bar.modulate = Color.GREEN.lerp(Color.YELLOW, 1-(health_percent-0.5)*2)	
	else:
		bar.modulate = Color.YELLOW.lerp(Color.DARK_RED, 1-(health_percent*2))
	bar.scale =  Vector2(health_percent, 1)
