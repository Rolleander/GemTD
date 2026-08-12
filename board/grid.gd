extends Node2D

@onready var map = $"../TileMap"
@export var texture : Texture2D

var width
var height

func _ready():
	var rect = map.get_used_rect()
	width = rect.size.x 
	height = rect.size.y 
	
	
func _draw():
	for x in width:
		for y in height:
			draw_texture(texture, Vector2(x* Globals.TILE_SIZE, y * Globals.TILE_SIZE))
