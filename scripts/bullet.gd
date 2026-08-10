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

func _ready():
	z_index = 20
	initial_distance = global_position.distance_to(target.global_position)
	curve_direction = -1.0 if randf() < 0.5 else 1.0
	curve_variation = randf_range(0.68, 1.2)
	curve_phase = randf_range(0.0, TAU)
	look_at(target.global_position)
	rotation += randf_range(-angle_spread, angle_spread)
	direction = Vector2(cos(rotation),sin(rotation)) 
	if trail!=null:
		trail.start()

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
	var render = get_child(0) as CanvasItem
	if render != null && !(render is GPUParticles2D):
		render.self_modulate.a = 0.0
	for light in find_children("*", "PointLight2D", true, false):
		(light as PointLight2D).visible = false

	var tween = create_tween()
	tween.tween_interval(particle_lifetime * 0.2)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, particle_lifetime * 0.8)
	tween.tween_callback(queue_free)

func _get_particle_emitters() -> Array[GPUParticles2D]:
	var emitters = [] as Array[GPUParticles2D]
	for node in find_children("*", "GPUParticles2D", true, false):
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
	var distance = global_position.distance_to(target.global_position)
	var target_direction = global_position.direction_to(target.global_position)
	var desired_direction = _curved_direction(target_direction, distance)
	var maxTurn = maxf(0.1, (turn_speed-distance) / turn_speed)
	direction = lerp(direction, desired_direction, maxTurn).normalized()
	if trail != null:
		trail.add_trail(global_position)
	#rotation = atan2(direction.x, direction.y)
	#position += direction * speed * delta
	#var dir = (target.global_position-global_position).normalized() 
	#direction = lerp(direction.rotated( randf_range(-randomness,randomness)), global_position.direction_to(target.global_position),0.05)
	if distance <= HIT_SIZE or _passed_through_target(previous_position, global_position):
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
	var current_curve: float = curve_strength * curve_variation * curve_wave * curve_fade
	var sideways = target_direction.orthogonal() * curve_direction
	return (target_direction + sideways * current_curve).normalized()

func _passed_through_target(from: Vector2, to: Vector2) -> bool:
	# A fast projectile may cross the entire hit radius between physics frames.
	var movement = to - from
	var movement_length_squared = movement.length_squared()
	if is_zero_approx(movement_length_squared):
		return false
	var target_offset = target.global_position - from
	var progress = clampf(target_offset.dot(movement) / movement_length_squared, 0.0, 1.0)
	var closest_point = from + movement * progress
	return closest_point.distance_squared_to(target.global_position) <= HIT_SIZE * HIT_SIZE
