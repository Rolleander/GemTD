extends Node2D

class_name Attack

enum Targeting{
	FIRST,
	SPREAD,
}

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
@export var splash_damage_factor : float = 0.5
@export var parallel_targets : int = 1
@export var targeting : Targeting = Targeting.FIRST

var gem : Gem
var active = false
var timer = Timer.new()
var attack_ready = false
var attack_scale = 1.0
var hit_damage_scale = 1.0
var hitlist = [] as Array[Enemy]

func _ready():
	add_child(timer)
	timer.start(gem.attack_delay.value)
	timer.timeout.connect(_on_timer_timeout)
	hit_buffs = _duplicate_e_buff(hit_buffs)
	aura_buffs = _duplicate_e_buff(aura_buffs)
	tower_buffs = _duplicate_t_buff(tower_buffs)
	Events.wave_started.connect(func(): hitlist.clear())

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

func _physics_process(delta):
	if !active:
		return
	if aura_buffs.size() > 0:
		_apply_aura_buffs()
	if !attack_ready:
		return
	var enemies = _targetable_enemies()	
	var targetCount = enemies.size()	
	var targets = 0
	var attacked = false
	if targeting == Targeting.SPREAD && targetCount > parallel_targets:
		enemies.sort_custom(_sort_targets)
	for enemy in enemies:
		targetCount-=1		
		if  targetCount < parallel_targets ||  _should_target(enemy):
			_attack(enemy)
			targets+=1
			attacked = true
			if targets >= parallel_targets:
				break
	if attacked:
		attack_ready  = false
		timer.start(gem.attack_delay.value)

func _targetable_enemies() -> Array[Enemy]:
	var enemies = [] as Array[Enemy]
	for enemy in Game.get_enemies():
		if !enemy.spawning &&  enemy.alive && _can_target(enemy) && Utils.in_range(self, enemy, gem.attack_range.value):
			enemies.append(enemy)
	return enemies 

func _sort_targets(a : Enemy, b : Enemy):
	if !_should_target(a):
		return false
	var hita = hitlist.find(a)
	var hitb = hitlist.find(b)
	if hita == -1 && hitb != -1:
		return b
	if hita != -1 && hitb == -1:
		return a
	return hita > hitb

func _should_target(enemy : Enemy) -> bool:
	if enemy.health.value - enemy.projected_damage <=0:
		return false
	return true
		
func _apply_aura_buffs():
	for enemy in Game.get_enemies():
		if enemy.alive && _can_target(enemy) && Utils.in_range(self, enemy, gem.attack_range.value):
			for buff in aura_buffs:
				BuffUtils.add_enemy_buff(enemy, gem, buff)

func _can_target(enemy : Enemy):
	if enemy.flying:
		return targets_air
	else:
		return targets_ground	
			
func _attack(target : Enemy):
	hitlist.erase(target)
	hitlist.push_front(target)

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
	#todo hit splash even when target died
	if splash_range > 0:
		for enemy in Game.get_enemies():
			if enemy != target && enemy.alive && Utils.in_range(enemy, target, splash_range):
				enemy.hit(self, splash_damage_factor)
	return hit

func _on_timer_timeout():
	attack_ready = true	
