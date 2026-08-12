extends Attack

class_name ProjectileAttack

@export var bullet_speed : float = 15
@export var bullet_source : Node2D
@export var angle_spread : float = 0.8
## How far projectiles bow away from a direct flight path. Zero flies directly.
@export_range(0.0, 3.0, 0.05) var curve_strength: float = 0.0

func _ready():
	super()
	Events.wave_ended.connect(cancel_projectiles)
	if bullet_source == null:
		push_error("ProjectileAttack '%s' has no bullet_source configured." % name)
		active = false
		set_physics_process(false)
		return
	bullet_source.visible = false

func cancel_projectiles():
	for child in get_children():
		var bullet := child as Bullet
		if bullet != null:
			bullet.cancel()
	
func _physics_process(delta):
	super(delta)

func _attack(enemy : Enemy):
	super(enemy)
	var bullet = _spawn_bullet(enemy)
	enemy.projected_damage += bullet.projected_damage
	add_child(bullet)	
	
func _spawn_bullet(enemy : Enemy):
	var bullet = Bullet.new()
	var attack_origin = gem.get_attack_origin_world_position()
	var trail_source = find_child("SmokeTrail")
	if trail_source != null:
		var trail = trail_source.duplicate() as SmokeTrail
		var trail_parent = get_tree().get_first_node_in_group("billboard_layer") as Node2D
		trail.position = Vector2.ZERO
		trail.width =  trail.width  * attack_scale
		trail_parent.add_child(trail)
		bullet.trail = trail
	bullet.position = to_local(attack_origin)
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
	bullet.angle_spread = angle_spread
	bullet.curve_strength = curve_strength
	bullet.set_render(render)
	render.visible = true
	return bullet
	
func bullet_hit(bullet : Bullet, target : Enemy):
	var store = hit_damage_scale
	hit_damage_scale = bullet.hit_damage_scale
	_hit(target)
	hit_damage_scale = store
