extends Node2D

class_name Bullet

const HIT_SIZE = 10

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
var fadeout = 0.15
var turn_speed = 200.0
var angle_spread

func _ready():
	z_index = 20
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
	var tween = create_tween()
	tween.set_trans( Tween.TRANS_CIRC)
	tween.set_ease( Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a",  0.0,  fadeout)
	tween.tween_callback(queue_free)
	var render = get_child(0) 
	if render is GPUParticles2D:
		render.emitting = false


func _physics_process(delta):
	if hit:
		return
	if !is_instance_valid(target):
		_stop()
		return
	rotation = direction.angle() 
	position += direction * (speed * Globals.GRID_SIZE) * delta
	var distance = global_position.distance_to(target.global_position)
	var maxTurn = maxf(0.1, (turn_speed-distance) / turn_speed)	
	direction = lerp(direction, global_position.direction_to(target.global_position),maxTurn)
	if trail != null:
		trail.add_trail(global_position)
	#rotation = atan2(direction.x, direction.y)
	#position += direction * speed * delta
	#var dir = (target.global_position-global_position).normalized() 
	#direction = lerp(direction.rotated( randf_range(-randomness,randomness)), global_position.direction_to(target.global_position),0.05)
	if distance <= HIT_SIZE :
		source.bullet_hit(self, target)
		target.projected_damage -= projected_damage
		_stop()
		return
		
	
