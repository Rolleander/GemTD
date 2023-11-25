extends Node2D

class_name Board

@onready var selection = $selection as Selection
@onready var camera = $Camera2D as Camera2D
@onready var tilemap = $TileMap as TileMap
@onready var maze = $Maze
@onready var rock_collision = $RockCollision
@onready var spawn_point = $spawn_point
@onready var waypoints = $waypoints
@onready var enemies = $Enemies
@onready var path_map = $PathMap as PathMap

# Called when the node enters the scene tree for the first time.
func _ready():
	NavigationServer2D.map_set_use_edge_connections(get_world_2d().navigation_map, false)
	var rect = tilemap.get_used_rect()
	var start = rect.position * Globals.TILE_SIZE 
	var end = rect.end * Globals.TILE_SIZE 
	camera.set_limit(SIDE_LEFT, start.x )
	camera.set_limit(SIDE_TOP, start.y )
	camera.set_limit(SIDE_RIGHT, end.x )
	camera.set_limit(SIDE_BOTTOM, end.y )

func _get_camera_rect() -> Rect2:
	var pos = camera.get_screen_center_position()
	var half_size = get_viewport_rect().size * 0.5
	#half_size.x = half_size.x / camera.scale.x
	#half_size.y = half_size.y / camera.scale.y
	return Rect2(pos - half_size, pos + half_size)
	
			
func _unhandled_input(event):
	if event.is_action_pressed("click"):
		_click()
	if event.is_action_pressed("start"):
		for e in Game.get_enemies():
			e.kill()

func _click():
	Game.clear_selection()
	if selection.visible:
		if Game.construction_phase && await _placement_allowed():
			Events.field_clicked.emit(selection.position)
		
func _placement_allowed() -> bool:
	var pos =  Vector2(selection.position)
	var path = [spawn_point.position]
	for w in waypoints.get_children():
		path.append(w.position)
	return await path_map.placing_allowed(pos, path)
		
func place_gem():	
	if !Game.construction_phase:
		return 
	var pos = $Marker.position
	var gem = preload("res://scenes/gem.tscn").instantiate()
	gem.under_construction = true
	gem.position = pos
	maze.add_child(gem)
	var type = Game.gem_chances.get_random_type()
	var quality = Game.gem_chances.get_random_quality()
	gem.init_basic_gem(type, quality)
	path_map.block_path(pos)
	Game.placed_gem(gem)
	$Marker.visible = false
	if Game.remaining_placements ==0:
		selection.visible = false
		
