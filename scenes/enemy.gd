extends CharacterBody2D

class_name Enemy 

@onready var navigation = $NavigationAgent2D
@onready var health_bar = $healthbar
@export var waypoints : Array[Node]
@onready var hit_effects = $HitEffects
@onready var sprite = $Sprite

var path = []
var target = -1
var max_health = 1000
var health = EnemyBuffableValue.new(self, EnemyBuff.Attribute.HEALTH, max_health)
var speed = EnemyBuffableValue.new(self, EnemyBuff.Attribute.SPEED, 150)
var armor = EnemyBuffableValue.new(self, EnemyBuff.Attribute.ARMOR, 1)
var damage_scale = 1.0
var started = false 
var alive = true
var projected_damage = 0
var flying = false
var buffs = [] as Array[EnemyBuffInstance]

func _ready():
	_next_waypoint()

func set_flying(flying : bool):
	self.flying = flying
	if flying:
		navigation.navigation_layers = 2
		collision_mask = 0
	else:
		navigation.navigation_layers = 1
		collision_mask = 2

func _next_waypoint():
	target+=1
	if target >= waypoints.size():
		kill()
		return
	navigation.target_position = waypoints[target].position	

func _process(delta):
	#_damage(1)
	health_bar.health_percent = float(health.value) / max_health 	
		
func _physics_process(delta : float):
	if !alive:
		return
	if navigation.is_navigation_finished():
		_next_waypoint()
	var dir = to_local(navigation.get_next_path_position()).normalized()
	navigation.max_speed = speed.value	
	navigation.velocity = dir * speed.value
	health.update()
	speed.update()
	armor.update()
	if health.value <=0:
		_death(null)
	BuffUtils.progress_enemy_buffs(self, delta)
		
func kill():
	_death(null)
		
func _damage(source : Attack) -> bool:
	if health.value <= 0:
		return false
	for buff in source.hit_buffs:
		BuffUtils.add_enemy_buff(self, source.gem, buff)	
	var damage = calc_damage(source.gem.damage.value * source.hit_damage_scale)
	health.value_add( damage *-1)
	if health.value <1:
		return true
	return false
		
func calc_damage(damage : float):
	return (damage / armor.value) * damage_scale
		
func hit(attack : Attack):
	if !alive:
		return
	if _damage(attack):
		_death(attack)

func _death(killer : Attack):
	if !alive:
		return
	alive = false
	Events.emit_signal("enemy_killed", self, killer)
	Events.delayed_destroy(self, 1)
	sprite.visible = false
	health_bar.visible = false
	if killer != null:
		killer.gem.killed(self)	

func add_hit_effect(effect : Node2D):
	hit_effects.add_child(effect)

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()

