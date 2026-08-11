extends Node2D

class_name Bullet

const HIT_SIZE = 10
const CURVE_FADE_DURATION = 4.0

#var direction = Vector2.RIGHT
var speed : float
var target : Enemy
var source : Attack 
#var randomness : float = 0.02
var projected_damage = 0
var direction  : Vector2
var trail : SmokeTrail
var hit_damage_scale = 1
var hit = false
var fadeout: float = 0.15
var turn_speed = 200.0
var angle_spread: float = 0.0
var curve_strength: float = 0.0
var curve_direction: float = 1.0
var curve_variation: float = 1.0
var curve_phase: float = 0.0
var initial_distance: float = 1.0
var flight_time: float = 0.0
var projectile_render: Node2D
var visual_billboard: Node2D
var world_particle_render: GPUParticles2D
var board: Board

func set_render(render: Node2D):
	projectile_render = render

func scale_render(scale_multiplier: float):
	if !is_instance_valid(projectile_render):
		return
	projectile_render.transform = projectile_render.transform.scaled(
		Vector2.ONE * scale_multiplier
	)

func _ready():
	process_priority = 10
	add_to_group("projectile_billboard_owner")
	board = get_tree().get_first_node_in_group("board") as Board
	visual_billboard = Node2D.new()
	visual_billboard.name = "ProjectileVisual"
	# A particle emitter must not begin simulating while the render is temporarily
	# attached to the world canvas for light extraction. Moving a live emitter to
	# the billboard canvas leaves its existing particles in the wrong coordinate
	# space, which makes them shift with camera movement.
	var particle_emitters = [] as Array[GPUParticles2D]
	if projectile_render is GPUParticles2D:
		particle_emitters.append(projectile_render as GPUParticles2D)
	for node in projectile_render.find_children("*", "GPUParticles2D", true, false):
		var emitter = node as GPUParticles2D
		if emitter != null:
			particle_emitters.append(emitter)
	var emitter_states = [] as Array[bool]
	for emitter in particle_emitters:
		emitter_states.append(emitter.emitting)
		emitter.emitting = false
	# Lights belong to the warped world canvas so they illuminate the map at the
	# logical bullet position. Only the visible projectile body is a billboard.
	add_child(projectile_render)
	for node in projectile_render.find_children("*", "PointLight2D", true, false):
		var light = node as PointLight2D
		if light != null:
			light.reparent(self, true)
	remove_child(projectile_render)
	add_child(visual_billboard)
	if projectile_render is GPUParticles2D:
		world_particle_render = projectile_render as GPUParticles2D
		var particle_layer = get_tree().get_first_node_in_group("projectile_particle_layer") as Node2D
		if particle_layer != null:
			particle_layer.add_child(world_particle_render)
		else:
			visual_billboard.add_child(projectile_render)
			world_particle_render = null
	else:
		visual_billboard.add_child(projectile_render)
	board.attach_billboard(visual_billboard)
	# Projectile particles must remain where they were emitted. Making them local
	# causes smoke-based bullets such as Emerald to collapse into a dark clump.
	for emitter in particle_emitters:
		emitter.local_coords = false
	tree_exiting.connect(_remove_visual_billboard)
	var target_position = _target_position()
	initial_distance = global_position.distance_to(target_position)
	curve_direction = -1.0 if randf() < 0.5 else 1.0
	curve_variation = randf_range(0.68, 1.2)
	curve_phase = randf_range(0.0, TAU)
	look_at(target_position)
	rotation += randf_range(-angle_spread, angle_spread)
	direction = Vector2(cos(rotation),sin(rotation)) 
	sync_billboard()
	for index in particle_emitters.size():
		var emitter = particle_emitters[index]
		emitter.restart()
		emitter.emitting = emitter_states[index]
	if trail!=null:
		trail.start()
		trail.add_trail(global_position)

func _process(_delta):
	sync_billboard()

func sync_billboard():
	if !is_instance_valid(board) || !is_instance_valid(visual_billboard):
		return
	if is_instance_valid(world_particle_render):
		world_particle_render.global_position = global_position
		world_particle_render.global_rotation = rotation
	board.update_billboard(visual_billboard, global_position)
	visual_billboard.z_index = Globals.ATTACK_PROJECTILE_Z_INDEX
	var screen_position = board.world_to_screen_position(global_position)
	var screen_ahead = board.world_to_screen_position(global_position + direction * 10.0)
	if !screen_position.is_equal_approx(screen_ahead):
		visual_billboard.rotation = screen_position.angle_to_point(screen_ahead)

func _remove_visual_billboard():
	if is_instance_valid(world_particle_render):
		world_particle_render.queue_free()
	if is_instance_valid(visual_billboard):
		visual_billboard.queue_free()

func _stop():
	if hit:
		return
	hit = true
	if trail != null:
		trail.stop()

	var particle_emitters = _get_particle_emitters()
	if particle_emitters.is_empty():
		# A normal projectile body should vanish on impact; only its detached trail
		# continues fading so the bullet never hangs motionless in the air.
		queue_free()
		return

	var particle_lifetime = fadeout
	for emitter in particle_emitters:
		emitter.emitting = false
		particle_lifetime = maxf(particle_lifetime, emitter.lifetime)

	# Hide a normal bullet body immediately while allowing particle children to
	# finish. self_modulate affects only the body, not its particle children.
	var render = projectile_render as CanvasItem
	if render != null && !(render is GPUParticles2D):
		render.self_modulate.a = 0.0
	for light in find_children("*", "PointLight2D", true, false):
		(light as PointLight2D).visible = false

	var fade_target: CanvasItem = visual_billboard
	if is_instance_valid(world_particle_render):
		fade_target = world_particle_render
	var tween = create_tween()
	tween.tween_interval(particle_lifetime * 0.2)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(fade_target, "modulate:a", 0.0, particle_lifetime * 0.8)
	tween.tween_callback(queue_free)

func _get_particle_emitters() -> Array[GPUParticles2D]:
	var emitters = [] as Array[GPUParticles2D]
	if is_instance_valid(world_particle_render):
		emitters.append(world_particle_render)
	if !is_instance_valid(visual_billboard):
		return emitters
	for node in visual_billboard.find_children("*", "GPUParticles2D", true, false):
		var emitter = node as GPUParticles2D
		if emitter != null:
			emitters.append(emitter)
	return emitters

func cancel():
	if hit:
		return
	if is_instance_valid(target):
		target.projected_damage = maxf(0.0, target.projected_damage - projected_damage)
	projected_damage = 0
	_stop()


func _physics_process(delta):
	if hit:
		return
	if !is_instance_valid(target):
		_stop()
		return
	flight_time += delta
	rotation = direction.angle()
	var previous_position = global_position
	position += direction * (speed * Globals.GRID_SIZE) * delta
	var target_position = _target_position()
	var distance = global_position.distance_to(target_position)
	var target_direction = global_position.direction_to(target_position)
	var desired_direction = _curved_direction(target_direction, distance)
	var maxTurn = maxf(0.1, (turn_speed-distance) / turn_speed)
	direction = lerp(direction, desired_direction, maxTurn).normalized()
	if trail != null:
		trail.add_trail(global_position)
	#rotation = atan2(direction.x, direction.y)
	#position += direction * speed * delta
	#var dir = (target.global_position-global_position).normalized() 
	#direction = lerp(direction.rotated( randf_range(-randomness,randomness)), global_position.direction_to(target.global_position),0.05)
	if distance <= HIT_SIZE or _passed_through_target(previous_position, global_position, target_position):
		source.bullet_hit(self, target)
		target.projected_damage -= projected_damage
		projected_damage = 0
		_stop()
		return
		


func _curved_direction(target_direction: Vector2, distance: float) -> Vector2:
	if is_zero_approx(curve_strength):
		return target_direction

	# Keep the bow broad during most of the flight, then fade it near the target
	# so even strongly curved projectiles converge reliably for the hit.
	var distance_ratio: float = clampf(distance / maxf(initial_distance, 1.0), 0.0, 1.0)
	var distance_fade: float = smoothstep(0.05, 0.68, distance_ratio)
	# Smoothly reduce the curve for the whole flight instead of visibly switching
	# modes. At four seconds the projectile is using pure direct homing.
	var time_fade: float = 1.0 - smoothstep(0.0, CURVE_FADE_DURATION, flight_time)
	var curve_fade: float = distance_fade * time_fade
	var wave_speed: float = lerpf(1.15, 1.85, curve_variation)
	var curve_wave: float = 0.84 + sin(flight_time * wave_speed + curve_phase) * 0.16
	# Start at the actual muzzle before opening into the wide bow. This is most
	# noticeable on Aquamarine, whose strong curve otherwise appears to begin
	# below or beside the gem on the first visible frames.
	var launch_fade = smoothstep(0.0, 0.18, flight_time)
	var current_curve: float = curve_strength * curve_variation * curve_wave * curve_fade * launch_fade
	var sideways = target_direction.orthogonal() * curve_direction
	return (target_direction + sideways * current_curve).normalized()

func _target_position() -> Vector2:
	if !is_instance_valid(target):
		return global_position
	return target.get_hit_world_position()

func _passed_through_target(from: Vector2, to: Vector2, target_position: Vector2) -> bool:
	# A fast projectile may cross the entire hit radius between physics frames.
	var movement = to - from
	var movement_length_squared = movement.length_squared()
	if is_zero_approx(movement_length_squared):
		return false
	var target_offset = target_position - from
	var progress = clampf(target_offset.dot(movement) / movement_length_squared, 0.0, 1.0)
	var closest_point = from + movement * progress
	return closest_point.distance_squared_to(target_position) <= HIT_SIZE * HIT_SIZE
