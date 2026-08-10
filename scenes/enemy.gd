extends CharacterBody2D

class_name Enemy

@onready var navigation = $NavigationAgent2D as NavigationAgent2D
@onready var health_bar = $healthbar
@export var waypoints: Array[Node]
@onready var hit_effects = $HitEffects
@onready var sprite = $Sprite
@onready var selection = $SelectionRing
@onready var animation = $AnimationPlayer
@onready var label = $Label
@onready var damage_smoke = $DamageSmoke as GPUParticles2D

const SMOKE_START_HEALTH_PERCENT := 0.4
const HIT_FLASH_COLOR := Color(1.0, 0.48, 0.48, 1.0)
const HIT_FLASH_DURATION := 0.16

var path = []
var target = -1
var max_health = 400
var health = EnemyBuffableValue.new(self, EnemyBuff.Attribute.HEALTH, max_health)
var speed = EnemyBuffableValue.new(self, EnemyBuff.Attribute.SPEED, 1)
var armor = EnemyBuffableValue.new(self, EnemyBuff.Attribute.ARMOR, 1)
var plating = EnemyBuffableValue.new(self, EnemyBuff.Attribute.PLATING, 0)
var limiter = EnemyBuffableValue.new(self, EnemyBuff.Attribute.LIMITER, 0)
var started = false
var alive = true
var projected_damage = 0
var flying = false
var buffs = [] as Array[EnemyBuffInstance]
var spawning = true
var money = 0
var killer = null
var hit_flash_tween: Tween

func _ready():
	($fire.material as ShaderMaterial).set_shader_parameter("offset", randf_range(-100, 100))
	_next_waypoint()

func set_flying(flying: bool):
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
	target += 1
	if target >= waypoints.size():
		Events.enemy_reached_end.emit(self)
		kill()
		return
	navigation.target_position = waypoints[target].position

func _process(delta):
	var health_percent := clampf(float(health.value) / max_health, 0.0, 1.0)
	health_bar.health_percent = health_percent
	_update_damage_smoke(health_percent)
		
func _physics_process(delta: float):
	spawning = false
	if !alive:
		return
	if navigation.is_navigation_finished():
		_next_waypoint()
	#$Label.text = str(target)+" | "+str(round(navigation.distance_to_target()))	
	var dir = to_local(navigation.get_next_path_position()).normalized()
	navigation.max_speed = (speed.value * Globals.GRID_SIZE)
	navigation.velocity = dir * (speed.value * Globals.GRID_SIZE)
	health.update()
	speed.update()
	armor.update()
	if health.value <= 0 && alive:
		_death(killer)
	BuffUtils.progress_enemy_buffs(self, delta)
		
func kill():
	_death(null)
		
func _damage(source: Attack, damage_factor: float = 1.0) -> bool:
	if health.value <= 0 || !alive:
		return false
	for buff in source.hit_buffs:
		BuffUtils.add_enemy_buff(self, source.gem, buff)
	health.update()
	var damage = calc_damage(source.gem.damage.value * damage_factor)
	source.gem.damage_dealt.dealt(damage)
	health.value_add(damage * -1)
	if damage > 0.0:
		_flash_on_hit()
	return health.value <= 0
		
func calc_damage(damage: float, ignore_attributes: Array[EnemyBuff.Attribute] = []):
	if !ignore_attributes.has(EnemyBuff.Attribute.LIMITER) && limiter.value > 0:
		damage = minf(damage, limiter.value)
	if !ignore_attributes.has(EnemyBuff.Attribute.PLATING):
		damage -= plating.value
	if !ignore_attributes.has(EnemyBuff.Attribute.ARMOR):
		damage = damage / armor.value
	return minf(damage, health.value)
		
func hit(attack: Attack, damage_factor: float = 1.0):
	if !alive:
		return
	if _damage(attack, damage_factor):
		_death(attack.gem)

func _death(killer: Gem):
	if !alive:
		return
	self.killer = killer
	input_pickable = false
	alive = false
	Events.enemy_killed.emit(self, killer)
	Events.delayed_destroy(self, 3)
	sprite.visible = false
	damage_smoke.emitting = false
	health_bar.visible = false
	selection.visible = false
	navigation.avoidance_enabled = false
	animation.play("explosion")
	if killer != null:
		killer.killed(self)

func add_hit_effect(effect: Node2D):
	hit_effects.add_child(effect)

func _flash_on_hit():
	if hit_flash_tween != null && hit_flash_tween.is_valid():
		hit_flash_tween.kill()
	sprite.self_modulate = HIT_FLASH_COLOR
	hit_flash_tween = create_tween()
	hit_flash_tween.set_trans(Tween.TRANS_QUAD)
	hit_flash_tween.set_ease(Tween.EASE_OUT)
	hit_flash_tween.tween_property(sprite, "self_modulate", Color.WHITE, HIT_FLASH_DURATION)

func _update_damage_smoke(health_percent: float):
	if !alive || health_percent >= SMOKE_START_HEALTH_PERCENT:
		damage_smoke.emitting = false
		return
	var damage_severity := clampf(
		(SMOKE_START_HEALTH_PERCENT - health_percent) / SMOKE_START_HEALTH_PERCENT,
		0.0,
		1.0
	)
	damage_smoke.amount_ratio = lerpf(0.08, 1.0, smoothstep(0.0, 1.0, damage_severity))
	damage_smoke.emitting = true

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	if !alive:
		return
	velocity = safe_velocity
	move_and_slide()

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		Events.enemy_selected.emit(self)
