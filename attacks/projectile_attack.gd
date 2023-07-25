extends Attack

class_name ProjectileAttack

@export var splash_range : float = 0
@export var bullet_speed : float = 15
@export var bullet_source : Node2D
@export var hit_buff : EnemyBuff

var timer = Timer.new()
var attack_ready = true

func _ready():
	bullet_source.visible = false
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta):
	if !active || !attack_ready:
		return
	for enemy in Game.get_enemies():
		if enemy.alive && in_range(self, enemy, attack_range):
			_attack(enemy)
			return
			
func _attack(enemy : Enemy):
	attack_ready  = false
	timer.start(attack_delay)
	var bullet = Bullet.new()
	bullet.target = enemy
	bullet.source = self
	bullet.speed = bullet_speed
	var render = bullet_source.duplicate()
	render.visible = true
	bullet.add_child(render)
	add_child(bullet)	
	
func bullet_hit(target : Enemy):
	target.hit(self)
	if splash_range > 0:
		for enemy in Game.get_enemies():
			if enemy != target && enemy.alive && in_range(enemy, target, splash_range):
				enemy.hit(self)
	
func _on_timer_timeout():
	attack_ready = true	
