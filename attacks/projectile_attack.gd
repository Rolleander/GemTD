extends Attack

class_name ProjectileAttack

@export var splash_range : float = 0
@export var bullet_speed : float = 15
@export var bullet_source : Node2D

var timer = Timer.new()
var attack_ready = true

func _ready():
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta):
	if Game.construction_phase || !attack_ready:
		return
	for enemy in Game.get_enemies():
		if enemy.alive && global_position.distance_to(enemy.global_position) <= attack_range/2:
			_attack(enemy)
			return
			
func _attack(enemy : Enemy):
	attack_ready  = false
	timer.start(attack_delay)
	var bullet = Bullet.new()
	bullet.target = enemy
	bullet.source = self
	bullet.speed = bullet_speed
	bullet.add_child(bullet_source.duplicate())
	add_child(bullet)	
	
func _on_timer_timeout():
	attack_ready = true	
