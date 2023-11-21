extends Node2D

class_name Selection
var marker : Node2D
var tilemap : TileMap
var valid_position : Vector2
var pathmap : PathMap

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(1,1,1,0.5)
	marker = get_parent().find_child("Marker")
	tilemap = get_parent().find_child("TileMap")
	pathmap = get_parent().find_child("PathMap")
	Events.unselect.connect(_unselect)
	Events.field_clicked.connect(_field_clicked)
	Events.gem_selected.connect(_gem_select)
	Events.wave_started.connect(_wave_started)

func _wave_started():
	visible = false
	marker.visible = false
	
func _gem_select(gem : Gem):
	marker.visible = false

func _unselect():
	marker.visible = false
	
func _field_clicked(location : Vector2):
	marker.position = location
	if Game.construction_phase && Game.remaining_placements >0:
		marker.visible = true

func valid_place():
	var grid_pos_1 = Vector2i((position / Globals.GRID_SIZE).round() )  
	var grid_pos_2 = Vector2i((position / Globals.GRID_SIZE).round() ) - Vector2i(1,1)
	var grid = tilemap.get_used_rect()
	grid.size.x *= 2
	grid.size.y *= 2
	if !grid.has_point(grid_pos_1) || !grid.has_point(grid_pos_2):		
		return false
	if pathmap.is_blocked(position):
		return false
	for x in 2:
		for y in 2:	
			var tile_pos = Vector2i((grid_pos_1 -Vector2i(x,y))/ 2) 
			if tilemap.get_cell_atlas_coords(0, tile_pos) ==Vector2i( 3,0): 
				return false
	return true

func _process(delta):
	if Game.construction_phase && Game.remaining_placements > 0:
		var pos = Vector2i((get_global_mouse_position() / Globals.GRID_SIZE).round() ) 
		position = (pos * Globals.GRID_SIZE) 
		visible = valid_place()
	else:
		visible = false
