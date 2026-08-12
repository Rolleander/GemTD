extends Node2D

class_name Board

@onready var world_perspective = $WorldPerspective
@onready var attack_particle_perspective = $AttackParticleLayer/Perspective
@onready var selection = $WorldPerspective/selection as Selection
@onready var camera = $Camera2D as BoardCamera
@onready var tilemap = $WorldPerspective/TileMap as TileMap
@onready var maze = $WorldPerspective/Maze
@onready var rock_collision = $WorldPerspective/RockCollision
@onready var spawn_point = $WorldPerspective/spawn_point
@onready var waypoints = $WorldPerspective/waypoints
@onready var enemies = $WorldPerspective/Enemies
@onready var path_map = $WorldPerspective/PathMap as PathMap

# Called when the node enters the scene tree for the first time.
func _ready():
	var perspective_material = world_perspective.material as ShaderMaterial
	perspective_material.set_shader_parameter("far_width", Globals.WORLD_FAR_WIDTH)
	perspective_material.set_shader_parameter("near_width", Globals.WORLD_NEAR_WIDTH)
	perspective_material.set_shader_parameter("far_y", Globals.WORLD_FAR_Y)
	perspective_material.set_shader_parameter("near_y", Globals.WORLD_NEAR_Y)
	var attack_perspective_material = attack_particle_perspective.material as ShaderMaterial
	attack_perspective_material.set_shader_parameter("far_width", Globals.WORLD_FAR_WIDTH)
	attack_perspective_material.set_shader_parameter("near_width", Globals.WORLD_NEAR_WIDTH)
	attack_perspective_material.set_shader_parameter("far_y", Globals.WORLD_FAR_Y)
	attack_perspective_material.set_shader_parameter("near_y", Globals.WORLD_NEAR_Y)
	NavigationServer2D.map_set_use_edge_connections(get_world_2d().navigation_map, false)
	var rect = tilemap.get_used_rect()
	var start = rect.position * Globals.TILE_SIZE
	var end = rect.end * Globals.TILE_SIZE
	camera.set_map_limits(start, end)

func _get_camera_rect() -> Rect2:
	var pos = camera.get_screen_center_position()
	var half_size = get_viewport_rect().size * 0.5
	#half_size.x = half_size.x / camera.scale.x
	#half_size.y = half_size.y / camera.scale.y
	return Rect2(pos - half_size, pos + half_size)
	
			
func _unhandled_input(event):
	if event.is_action_pressed("click"):
		_click()

func _click():
	selection.update_position_from_mouse()
	if _select_object_at(get_viewport().get_mouse_position()):
		return
	Game.clear_selection()
	if !selection.visible || !selection.valid_place():
		return
	var placement_position: Vector2 = selection.position
	if Game.construction_phase && await _placement_allowed(placement_position):
		Events.field_clicked.emit(placement_position)
		
func _placement_allowed(pos: Vector2) -> bool:
	var path = [spawn_point.position]
	for w in waypoints.get_children():
		path.append(w.position)
	return await path_map.placing_allowed(pos, path)
		
func place_gem():
	if !Game.construction_phase:
		return
	var pos = $WorldPerspective/Marker.position
	var gem = preload("res://gems/gem.tscn").instantiate()
	gem.under_construction = true
	gem.position = pos
	maze.add_child(gem)
	var type = Game.gem_chances.get_random_type()
	var quality = Game.gem_chances.get_random_quality()
	gem.init_basic_gem(type, quality)
	path_map.block_path(pos)
	Game.placed_gem(gem)
	$WorldPerspective/Marker.visible = false
	if Game.remaining_placements == 0:
		selection.visible = false

func get_world_mouse_position() -> Vector2:
	return screen_to_world_position(get_viewport().get_mouse_position())

func screen_to_world_position(screen_position: Vector2) -> Vector2:
	var viewport = get_viewport()
	var viewport_size = viewport.get_visible_rect().size
	var unwarped_screen_position = Globals.unwarp_world_screen_position(
		screen_position,
		viewport_size
	)
	return viewport.get_canvas_transform().affine_inverse() * unwarped_screen_position

func world_to_screen_position(world_position: Vector2) -> Vector2:
	var viewport = get_viewport()
	var viewport_size = viewport.get_visible_rect().size
	var source_screen_position = viewport.get_canvas_transform() * world_position
	return Globals.warp_world_screen_position(source_screen_position, viewport_size)

func attach_billboard(billboard: Node2D) -> void:
	var billboard_layer = get_tree().get_first_node_in_group("billboard_layer") as Node2D
	if billboard_layer == null:
		push_error("Billboard layer was not found.")
		return
	billboard.reparent(billboard_layer)
	configure_billboard_particles(billboard)

func configure_billboard_particles(billboard: Node2D) -> void:
	for child in billboard.find_children("*", "GPUParticles2D", true, false):
		var particles = child as GPUParticles2D
		if particles != null:
			particles.local_coords = true

func update_billboard(billboard: Node2D, world_position: Vector2) -> void:
	if !is_instance_valid(billboard):
		return
	var viewport = get_viewport()
	var viewport_size = viewport.get_visible_rect().size
	var source_screen_position = viewport.get_canvas_transform() * world_position
	var projected_position = Globals.warp_world_screen_position(
		source_screen_position,
		viewport_size
	)
	var perspective_scale = Globals.world_billboard_perspective_scale(
		source_screen_position,
		viewport_size
	)
	billboard.position = projected_position
	billboard.scale = Vector2.ONE * camera.zoom.x * perspective_scale
	billboard.z_index = clampi(roundi(projected_position.y), -4096, 4096)

func update_all_billboards() -> void:
	for child in maze.get_children():
		var gem = child as Gem
		if gem != null:
			gem.sync_billboard()
	for child in enemies.get_children():
		var enemy = child as Enemy
		if enemy != null:
			enemy.sync_billboard()
	for projectile in get_tree().get_nodes_in_group("projectile_billboard_owner"):
		if is_instance_valid(projectile):
			projectile.sync_billboard()

func _select_object_at(screen_position: Vector2) -> bool:
	var closest_enemy: Enemy = null
	var closest_enemy_distance = INF
	for candidate in enemies.get_children():
		var enemy = candidate as Enemy
		if enemy == null || !enemy.alive:
			continue
		var distance = enemy.get_click_screen_position().distance_to(screen_position)
		if distance <= enemy.get_click_radius_screen() && distance < closest_enemy_distance:
			closest_enemy = enemy
			closest_enemy_distance = distance
	if closest_enemy != null:
		Game.clear_selection()
		Events.enemy_selected.emit(closest_enemy)
		return true

	var world_position = screen_to_world_position(screen_position)
	var closest_gem: Gem = null
	var closest_gem_distance = float(Globals.GRID_SIZE)
	for candidate in maze.get_children():
		var gem = candidate as Gem
		if gem == null:
			continue
		var distance = gem.position.distance_to(world_position)
		if distance <= closest_gem_distance:
			closest_gem = gem
			closest_gem_distance = distance
	if closest_gem != null:
		Game.clear_selection()
		Events.gem_selected.emit(closest_gem)
		return true
	return false
