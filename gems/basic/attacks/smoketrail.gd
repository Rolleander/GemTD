extends Line2D

class_name SmokeTrail

@export var limited_lifetime := false
@export var wildness := 3.0
@export var min_spawn_distance := 5.0

var lifetime := [1.2, 1.6]
var tick_speed := 0.05
var tick := 0.0
var wild_speed := 0.1
var point_age := [0.0]
var stopped := false
var world_points = [] as Array[Vector2]
var board: Board

func start():
	process_priority = 10
	z_index = Globals.ATTACK_TRAIL_Z_INDEX
	clear_points()
	point_age.clear()
	world_points.clear()
	board = get_tree().get_first_node_in_group("board") as Board
	if limited_lifetime:
		stop()
		
func stop():
	if stopped:
		return
	stopped = true
	var tween = create_tween()
	tween.set_trans( Tween.TRANS_CIRC)
	tween.set_ease( Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a",  0.0,  randf_range(lifetime[0], lifetime[1]))
	tween.tween_callback(queue_free)

func _process(delta):
	if tick > tick_speed:
		tick = 0
		# Keep the launch point anchored. Moving it makes high-wildness trails look
		# as if the projectile originated beside or below the tower.
		for p in range(1, world_points.size()):
			point_age[p] += 5*delta
			var rand_vector = Vector2( randf_range(-wild_speed, wild_speed), randf_range(-wild_speed, wild_speed) )
			world_points[p] += rand_vector * wildness * point_age[p]
		#if stopped:
			# This part is optional and only servers visual polishing purposes.
			# If a trail is stopped, and a very intense gradient is used, this part can be left in to change the
			# gradient of the line slowly towards a softer end.
			# Performance wise it's slower than the variant without this part, but it looks much better for glowing
			# trails like rockets with a longer life time
			#gradient.offsets[2] = clamp(gradient.offsets[2]+0.04, 0.0, 0.99)
			#gradient.offsets[1] = clamp(gradient.offsets[1]+0.04, 0.0, 0.98)
			#gradient.colors[2] = lerp(gradient.colors[2], gradient.colors[1], 0.1 )
			#gradient.colors[3] = lerp(gradient.colors[3], gradient.colors[0], 0.2 )
			#width += 3
	else:
		tick += delta
	_update_projected_points()


func add_trail(point_pos:Vector2, at_pos = -1):
	if !world_points.is_empty() and point_pos.distance_to(world_points[world_points.size() - 1]) < min_spawn_distance:
		return
	if at_pos < 0 || at_pos >= world_points.size():
		world_points.append(point_pos)
		point_age.append(0.0)
	else:
		world_points.insert(at_pos, point_pos)
		point_age.insert(at_pos, 0.0)
	_update_projected_points()

func _update_projected_points():
	if !is_instance_valid(board):
		return
	var projected_points = PackedVector2Array()
	for world_point in world_points:
		projected_points.append(board.world_to_screen_position(world_point))
	points = projected_points
