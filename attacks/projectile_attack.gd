extends Attack

class_name ProjectileAttack

@export var bullet_speed : float = 15
@export var bullet_source : Node2D

func _ready():
	super()
	bullet_source.visible = false

func _physics_process(delta):
	super(delta)

func _attack(enemy : Enemy):
	if enemy.health - enemy.projected_damage <=0:
		return false
	enemy.projected_damage += damage	
	var bullet = Bullet.new()
	bullet.target = enemy
	bullet.source = self
	bullet.speed = bullet_speed
	var render = bullet_source.duplicate()
	render.visible = true
	bullet.add_child(render)
	bullet.look_at(enemy.global_position)
	add_child(bullet)	
	return true
	
func bullet_hit(target : Enemy):
	_hit(target)
	target.projected_damage-=damage
