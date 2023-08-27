extends Node2D

class_name Attack

@export var damage : float
@export var attack_range : float
@export var attack_delay : float = 1
@export var description : String 
@export var targets_air : bool = true
@export var targets_ground : bool = true
@export var hit_buffs : Array[EnemyBuff]
@export var aura_buffs : Array[EnemyBuff]
@export var hit_effect : GPUParticles2D
@export var tower_buffs : Array[TowerBuff]
@export var splash_range : float = 0
@export var parallel_targets : int = 1

var gem : Gem
var active = false
var timer = Timer.new()
var attack_ready = false
var attack_scale = 1.0
var hit_damage_scale = 1.0

func _ready():
	add_child(timer)
	timer.start(gem.attack_delay.value)
	timer.timeout.connect(_on_timer_timeout)
	hit_buffs = _duplicate_e_buff(hit_buffs)
	aura_buffs = _duplicate_e_buff(aura_buffs)
	tower_buffs = _duplicate_t_buff(tower_buffs)

func _duplicate_e_buff(array : Array):
	var duplicates = [] as Array[EnemyBuff]
	for a in array:
		duplicates.append(a.duplicate())
	return duplicates
	
func _duplicate_t_buff(array : Array):
	var duplicates = [] as Array[TowerBuff]
	for a in array:
		duplicates.append(a.duplicate())
	return duplicates

func init():
	if gem.quality ==null || gem.type == null:
		return
	var type_info = Globals.get_gem_info(gem.type)
	var quality_info = Globals.get_quality_info(gem.quality)
	damage = round(damage* quality_info.damage_scale)
	attack_range *= quality_info.range_scale
	attack_delay *= quality_info.attack_delay_scale
	attack_scale += gem.quality *.05

func _physics_process(delta):
	if !active:
		return
	if aura_buffs.size() > 0:
		_apply_aura_buffs()
	if !attack_ready:
		return
	var targets = 0
	var attacked = false
	for enemy in Game.get_enemies():
		if enemy.alive && _can_target(enemy) && in_range(self, enemy, gem.attack_range.value):
			if _attack(enemy):
				targets+=1
				attacked = true
				if targets >= parallel_targets:
					break
	if attacked:
		attack_ready  = false
		timer.start(gem.attack_delay.value)
		
func _apply_aura_buffs():
	for enemy in Game.get_enemies():
		if enemy.alive && _can_target(enemy) && in_range(self, enemy, gem.attack_range.value):
			for buff in aura_buffs:
				BuffUtils.add_enemy_buff(enemy, gem, buff)

func _can_target(enemy : Enemy):
	if enemy.flying:
		return targets_air
	else:
		return targets_ground	
			
func _attack(target : Enemy):
	return false

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
