extends Node2D

class_name Bullet

const HIT_SIZE = 10
#var direction = Vector2.RIGHT
var speed : float
var target : Enemy
var source : Attack 
#var randomness : float = 0.02
var projected_damage = 0
var direction  
var trail : SmokeTrail
var hit_damage_scale = 1


func _ready():
	z_index = 20
	direction = (target.global_position-global_position).normalized() 
	if trail!=null:
		trail.start()

func _physics_process(delta):
	if !is_instance_valid(target) || !target.alive:
		queue_free()
		return
	look_at(target.global_position)
	position += direction * speed * delta
	direction = lerp(direction, global_position.direction_to(target.global_position),0.1)
	if trail != null:
		trail.add_trail(global_position)
	#rotation = atan2(direction.x, direction.y)
	#position += direction * speed * delta
	#var dir = (target.global_position-global_position).normalized() 
	#direction = lerp(direction.rotated( randf_range(-randomness,randomness)), global_position.direction_to(target.global_position),0.05)
	if global_position.distance_to(target.global_position) <= HIT_SIZE :
		source.bullet_hit(self, target)
		target.projected_damage -= projected_damage
		if trail != null:
			trail.stop()
		queue_free()
		return
		
	
