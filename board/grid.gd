extends Node2D

@onready var map = $"../TileMap"
@export var texture: Texture2D

var width
var height

func _ready():
	const edge_tiles = 8
	var rect = map.get_used_rect()
	width = rect.size.x - edge_tiles
	height = rect.size.y - edge_tiles
	
	
func _draw():
	for x in width:
		for y in height:
			draw_texture(texture, Vector2(x * Globals.TILE_SIZE, y * Globals.TILE_SIZE))
