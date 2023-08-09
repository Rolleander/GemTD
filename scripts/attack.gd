extends Node2D

class_name Attack

@export var damage : float
@export var attack_range : float
@export var attack_delay : float = 1
@export var description : String 
@export var targets_air : bool = true
@export var targets_ground : bool = true
@export var hit_buff : EnemyBuff
@export var hit_effect : GPUParticles2D
@export var splash_range : float = 0
@export var parallel_targets : int = 1

var gem : Gem
var active = false
var timer = Timer.new()
var attack_ready = false

func _ready():
	add_child(timer)
	timer.start(attack_delay)
	timer.timeout.connect(_on_timer_timeout)

func init():
	if gem.quality ==null || gem.type == null:
		return
	var type_info = Globals.get_gem_info(gem.type)
	var quality_info = Globals.get_quality_info(gem.quality)
	damage = round(damage* quality_info.damage_scale)
	attack_range *= quality_info.range_scale
	attack_delay *= quality_info.attack_delay_scale

func _physics_process(delta):
	if !active || !attack_ready:
		return
	var targets = 0
	var attacked = false
	for enemy in Game.get_enemies():
		if enemy.alive && in_range(self, enemy, attack_range):
			_attack(enemy)
			targets+=1
			attacked = true
			if targets >= parallel_targets:
				break
	if attacked:
		attack_ready  = false
		timer.start(attack_delay)
			
func _attack(target : Enemy):
	pass

func in_range(source : Node2D, target : Node2D, range : float) -> bool:
	return source.global_position.distance_to(target.global_position) <= range/ 2

func _hit(target : Enemy):
	target.hit(self)
	var hit = null
	if hit_effect!= null:
		hit = hit_effect.duplicate()
		target.add_hit_effect(hit)
		hit.visible = true
		hit.one_shot = true
		hit.emitting = true
		Events.delayed_destroy(hit, hit.lifetime * 1.5)
	if splash_range > 0:
		for enemy in Game.get_enemies():
			if enemy != target && enemy.alive && in_range(enemy, target, splash_range):
				enemy.hit(self)
	return hit

func _on_timer_timeout():
	attack_ready = true	
