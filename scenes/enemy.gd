extends CharacterBody2D

class_name Enemy 

signal enemy_died(enemy: Enemy)


@onready var navigation = $NavigationAgent2D
@onready var health_bar = $healthbar
@export var waypoints : Array[Node]
@export var speed = 150

var path = []
var target = -1
var max_health = 20
var health = max_health
var started = false 
var alive = true

func _ready():
	navigation.max_speed = speed
	_next_waypoint()

func _next_waypoint():
	target+=1
	if target >= waypoints.size():
		_death()
		return
	navigation.target_position = waypoints[target].position	

func _process(delta):
	#_damage(1)
	health_bar.health_percent = float(health) / max_health 	
		
func _physics_process(_delta : float):
	if navigation.is_navigation_finished():
		_next_waypoint()
	var dir = to_local(navigation.get_next_path_position()).normalized()
	navigation.velocity = dir * speed
		
func _damage(damage) -> bool:
	if health <= 0:
		return false
	health-=1
	if health <1:
		_death()
		return true
	return false
		
func hit(attack : Attack):
	if _damage(attack.damage):
		attack.gem.killed(self)	

func _death():
	emit_signal("enemy_died", self)
	queue_free()


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()

