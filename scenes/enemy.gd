extends CharacterBody2D

class_name Enemy 

@onready var navigation = $NavigationAgent2D
@onready var health_bar = $healthbar
@export var waypoints : Array[Node]
@onready var hit_effects = $HitEffects
@onready var sprite = $Sprite
@onready var selection = $SelectionRing

var path = []
var target = -1
var max_health = 400
var health = EnemyBuffableValue.new(self,EnemyBuff.Attribute.HEALTH, max_health)
var speed = EnemyBuffableValue.new(self, EnemyBuff.Attribute.SPEED, 1)
var armor = EnemyBuffableValue.new(self, EnemyBuff.Attribute.ARMOR, 1)
var plating =  EnemyBuffableValue.new(self, EnemyBuff.Attribute.PLATING, 0)
var limiter =  EnemyBuffableValue.new(self, EnemyBuff.Attribute.LIMITER, 0)
var started = false 
var alive = true
var projected_damage = 0
var flying = false
var buffs = [] as Array[EnemyBuffInstance]
var spawning = true
var money = 0
var killer = null

func _ready():
	_next_waypoint()

func set_flying(flying : bool):
	self.flying = flying
	if flying:
		navigation.navigation_layers = 2
		collision_mask = 0
		z_index = 5
	else:
		navigation.navigation_layers = 1
		collision_mask = 2
		z_index = 0

func _next_waypoint():
	target+=1
	if target >= waypoints.size():
		kill()
		return
	navigation.target_position = waypoints[target].position	

func _process(delta):
	health_bar.health_percent = clampf(float(health.value) / max_health ,0,1)
		
func _physics_process(delta : float):
	spawning = false
	if !alive:
		return
	if navigation.is_navigation_finished():
		_next_waypoint()
	var dir = to_local(navigation.get_next_path_position()).normalized()
	navigation.max_speed = (speed.value	* Globals.GRID_SIZE)
	navigation.velocity = dir * (speed.value * Globals.GRID_SIZE)
	health.update()
	speed.update()
	armor.update()
	if health.value <=0 && alive:
		_death(killer)
	BuffUtils.progress_enemy_buffs(self, delta)
		
func kill():
	_death(null)
		
func _damage(source : Attack, damage_factor : float = 1.0) -> bool:
	if health.value <= 0 || !alive:
		return false
	for buff in source.hit_buffs:
		BuffUtils.add_enemy_buff(self, source.gem, buff)	
	health.update()
	var damage = calc_damage(source.gem.damage.value * damage_factor)
	source.gem.damage_dealt.dealt(damage)
	health.value_add( damage *-1)
	return health.value <= 0
		
func calc_damage(damage : float, ignore_attributes : Array[EnemyBuff.Attribute] = []):
	if !ignore_attributes.has(EnemyBuff.Attribute.LIMITER) && limiter.value > 0:
		damage = minf(damage, limiter.value)
	if !ignore_attributes.has(EnemyBuff.Attribute.PLATING):
		damage -= plating.value
	if !ignore_attributes.has(EnemyBuff.Attribute.ARMOR):
		damage = damage / armor.value
	return minf(damage, health.value)
		
func hit(attack : Attack, damage_factor : float = 1.0):
	if !alive:
		return
	if _damage(attack, damage_factor):
		_death(attack.gem)

func _death(killer : Gem):
	if !alive:
		return
	self.killer = killer	
	alive = false
	Events.enemy_killed.emit(self, killer)
	Events.delayed_destroy(self, 1)
	sprite.visible = false
	health_bar.visible = false
	selection.visible = false
	navigation.avoidance_enabled = false
	if killer != null:
		killer.killed(self)	

func add_hit_effect(effect : Node2D):
	hit_effects.add_child(effect)

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	if !alive:
		return
	velocity = safe_velocity
	move_and_slide()

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		Events.enemy_selected.emit(self)
