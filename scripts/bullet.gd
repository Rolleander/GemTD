extends Node2D

class_name Bullet

const HIT_SIZE = 5
var speed : float
var target : Enemy
var source : Attack 

func _ready():
	z_index = 20

func _physics_process(delta):
	if !is_instance_valid(target) || !target.alive:
		queue_free()
		return
	look_at(target.global_position)
	var dir = (target.global_position-global_position).normalized() 
	position += dir * speed * delta
	if global_position.distance_to(target.global_position) <= HIT_SIZE :
		source.bullet_hit(target)
		queue_free()
		return
		
	
