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
	super(enemy)
	var bullet = _spawn_bullet(enemy)
	enemy.projected_damage += bullet.projected_damage
	add_child(bullet)	
	
func _spawn_bullet(enemy : Enemy):
	var bullet = Bullet.new()
	var trail_source = find_child("SmokeTrail")
	if trail_source != null:
		var trail = trail_source.duplicate() as SmokeTrail
		trail.position = self.position
		trail.width =  trail.width  * attack_scale
		get_tree().get_first_node_in_group("TrailNode").add_child(trail)
		bullet.trail = trail
	bullet.target = enemy
	bullet.source = self
	bullet.speed = bullet_speed
	bullet.projected_damage = enemy.calc_damage(gem.damage.value * hit_damage_scale)	
	bullet.hit_damage_scale = hit_damage_scale
	var render = bullet_source.duplicate(0b1110) as Node2D
	if render is GPUParticles2D:
		var material = (render.process_material as ParticleProcessMaterial).duplicate()
		material.scale_min *= attack_scale
		material.scale_max *= attack_scale
		render.process_material = material
	else:	
		render.transform =  render.transform.scaled(Vector2(attack_scale, attack_scale))
	bullet.add_child(render)
	bullet.look_at(enemy.global_position)	
	render.visible=true
	return bullet
	
func bullet_hit(bullet : Bullet, target : Enemy):
	var store = hit_damage_scale
	hit_damage_scale = bullet.hit_damage_scale
	_hit(target)
	hit_damage_scale = store
