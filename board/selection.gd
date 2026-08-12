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

func valid_place() -> bool:
	var grid_pos := Vector2i((position / Globals.GRID_SIZE).round())
	if pathmap.is_blocked(position):
		return false
	for x in 2:
		for y in 2:
			var occupied_cell := grid_pos - Vector2i(x, y)
			if !_is_playable_map_cell(occupied_cell):
				return false
	return true


func _is_playable_map_cell(grid_cell: Vector2i) -> bool:
	if pathmap.get_cell_source_id(0, grid_cell) == -1:
		return false
	var map_cell := Vector2i(
		floori(grid_cell.x / 2.0),
		floori(grid_cell.y / 2.0)
	)
	var atlas_coords := tilemap.get_cell_atlas_coords(0, map_cell)
	return atlas_coords != Vector2i(3, 0)

func update_position_from_mouse() -> void:
	var board = get_tree().get_first_node_in_group("board") as Board
	var mouse_position = board.get_world_mouse_position()
	var grid_pos := Vector2i((mouse_position / Globals.GRID_SIZE).round())
	position = grid_pos * Globals.GRID_SIZE
	visible = valid_place()


func _process(_delta):
	if Game.construction_phase && Game.remaining_placements > 0:
		update_position_from_mouse()
	else:
		visible = false
