extends Node2D

@onready var selection = $selection as Selection
@onready var camera = $Camera2D
@onready var tilemap = $TileMap
@onready var maze = $Maze
@onready var rock_collision = $RockCollision
@onready var spawn_point = $spawn_point
@onready var waypoints = $waypoints
@onready var enemies = $Enemies
@onready var path_map = $PathMap as PathMap

const ZOOM_SPEED = 0.1
const MIN_ZOOM = 0.8 
const MAX_ZOOM = 2
var _zoom_level = 1.5

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.wave_started.connect(func(): selection.visible = false)
	NavigationServer2D.map_set_use_edge_connections(get_world_2d().navigation_map, false)
	var rect = tilemap.get_used_rect()
	var start = rect.position * Globals.TILE_SIZE 
	var end = rect.end * Globals.TILE_SIZE 
	camera.set_limit(SIDE_LEFT, start.x)
	camera.set_limit(SIDE_TOP, start.y)
	camera.set_limit(SIDE_RIGHT, end.x)
	camera.set_limit(SIDE_BOTTOM, end.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if Game.construction_phase && Game.remaining_placements > 0:
		var pos = Vector2i((get_local_mouse_position() / Globals.GRID_SIZE).round() ) 
		selection.visible = selection.valid_place()
		selection.position = (pos * Globals.GRID_SIZE) 

func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		_set_zoom_level(_zoom_level + ZOOM_SPEED)
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(_zoom_level - ZOOM_SPEED)
	if event.is_action_pressed("click"):
		click()
	if event.is_action_pressed("start"):
		for e in Game.get_enemies():
			e.kill()
	

func _set_zoom_level(value: float) -> void:
	# We limit the value between `min_zoom` and `max_zoom`
	_zoom_level = clamp(value, MIN_ZOOM, MAX_ZOOM)
	var tween = create_tween()
	# Then, we ask the tween node to animate the camera's `zoom` property from its current value
	# to the target zoom level.
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(camera, "zoom", Vector2(_zoom_level, _zoom_level),	0.2)

func click():#
	if Game.construction_phase:
		if selection.valid_place():
			place_gem()
	else:
		Game.clear_selection()
		
func place_gem():	
	if !Game.construction_phase || Game.remaining_placements <= 0:
		return 
	var pos = selection.position
	var path = [spawn_point.position]
	for w in waypoints.get_children():
		path.append(w.position)
	if  ! await path_map.placing_allowed(pos, path):
		return
	var gem = preload("res://scenes/gem.tscn").instantiate()
	gem.position = pos
	maze.add_child(gem)
	gem.init_basic_gem(Game.gem_chances.get_random_type(), Game.gem_chances.get_random_quality())
	path_map.block_path(pos)
	Game.placed_gem(gem)
	if Game.remaining_placements ==0:
		selection.visible = false
		
