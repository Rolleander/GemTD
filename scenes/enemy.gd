extends CharacterBody2D

class_name Enemy 

@onready var navigation = $NavigationAgent2D
@onready var health_bar = $healthbar
@export var waypoints : Array[Node]
@export var speed = 80

var path = []
var target = -1
var max_health = 300
var health = max_health
var started = false 
var alive = true

func _ready():
	navigation.max_speed = speed
	_next_waypoint()

func _next_waypoint():
	target+=1
	if target >= waypoints.size():
		kill()
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
		
func kill():
	_death(null)
		
func _damage(damage, source : Attack) -> bool:
	if health <= 0:
		return false
	health-=damage
	if health <1:
		_death(source)
		return true
	return false
		
func hit(attack : Attack):
	if !alive:
		return
	if _damage(attack.damage, attack):
		attack.gem.killed(self)	

func _death(killer : Attack):
	Events.emit_signal("enemy_killed", self, killer)
	queue_free()

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()

