extends CharacterBody2D

class_name Enemy

@onready var navigation = $NavigationAgent2D as NavigationAgent2D
@onready var visual_billboard = $VisualBillboard
@onready var shadow = $Shadow
@onready var health_bar = $VisualBillboard/healthbar
@export var waypoints: Array[Node]
@onready var hit_effects = $VisualBillboard/HitEffects
@onready var sprite = $VisualBillboard/Sprite
@onready var selection = $SelectionRing
@onready var death_light = $PointLight2D
@onready var animation = $VisualBillboard/AnimationPlayer
@onready var fire = $VisualBillboard/fire
@onready var label = $VisualBillboard/Label
@onready var damage_smoke = $VisualBillboard/DamageSmoke as GPUParticles2D
@onready var pixel_explosion_warmup = $VisualBillboard/PixelExplosionWarmup as Sprite2D
@onready var board = get_tree().get_first_node_in_group("board") as Board

const SMOKE_START_HEALTH_PERCENT := 0.4
const HIT_FLASH_COLOR := Color(1.0, 0.48, 0.48, 1.0)
const HIT_FLASH_DURATION := 0.16
const FLYING_VISUAL_HEIGHT = 52.0
const NORMAL_SHADOW_OFFSET = Vector2(-4.0, 6.0)
const FLYING_SHADOW_OFFSET = Vector2.ZERO
const DAMAGE_SMOKE_TEXTURE = preload("res://sprites/smoke_particle.png")
const PIXEL_EXPLOSION_DURATION = 0.65

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
var shadow_billboard: Node2D
var smoke_spawn_timer = 0.0

func _ready():
	process_priority = 10
	# Selection belongs to the displayed enemy, not its navigation point. This
	# keeps the ring around raised flying enemies as well as ground enemies.
	selection.reparent(visual_billboard, false)
	selection.position = sprite.position
	shadow_billboard = Node2D.new()
	shadow_billboard.name = "ShadowBillboard"
	add_child(shadow_billboard)
	shadow.reparent(shadow_billboard)
	shadow.position = Vector2.ZERO
	board.attach_billboard(shadow_billboard)
	board.attach_billboard(visual_billboard)
	# GPU particles cannot both remain in projected world space and leave their
	# moving emitter. Projected smoke puffs are emitted in _update_damage_smoke.
	damage_smoke.emitting = false
	damage_smoke.visible = false
	sync_billboard()
	tree_exiting.connect(_remove_billboard)
	(fire.material as ShaderMaterial).set_shader_parameter("offset", randf_range(-100, 100))
	_next_waypoint()
	Events.delayed(_hide_pixel_explosion_warmup, 0.15)

func _hide_pixel_explosion_warmup():
	if is_instance_valid(pixel_explosion_warmup):
		pixel_explosion_warmup.visible = false

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
	sync_billboard()

func _next_waypoint():
	target += 1
	if target >= waypoints.size():
		Events.enemy_reached_end.emit(self)
		kill()
		return
	navigation.target_position = waypoints[target].position

func _process(delta):
	sync_billboard()
	var health_percent := clampf(float(health.value) / max_health, 0.0, 1.0)
	health_bar.health_percent = health_percent
	_update_damage_smoke(health_percent, delta)
		
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
	# The light lives in the warped world canvas so it can illuminate the map,
	# but flying enemies display their sprite above their navigation position.
	# Move the death flash to that displayed center before starting the effect.
	death_light.global_position = get_hit_world_position()
	self.killer = killer
	input_pickable = false
	alive = false
	Events.enemy_killed.emit(self, killer)
	Events.delayed_destroy(self, 3)
	shadow.visible = false
	_start_pixel_explosion()
	damage_smoke.emitting = false
	health_bar.visible = false
	selection.visible = false
	navigation.avoidance_enabled = false
	animation.play("explosion")
	death_light.energy = 0.0
	if killer != null:
		killer.killed(self)

func _start_pixel_explosion():
	if hit_flash_tween != null && hit_flash_tween.is_valid():
		hit_flash_tween.kill()
	sprite.self_modulate = Color.WHITE
	sprite.visible = true

	var warmup_material = pixel_explosion_warmup.material as ShaderMaterial
	if warmup_material == null:
		push_error("Enemy pixel explosion warmup requires a ShaderMaterial.")
		sprite.visible = false
		return
	var explosion_material = warmup_material.duplicate() as ShaderMaterial
	explosion_material.set_shader_parameter("progress", 0.0)
	explosion_material.set_shader_parameter("use_region", sprite.region_enabled)
	if sprite.region_enabled:
		explosion_material.set_shader_parameter("region_position_px", sprite.region_rect.position)
		explosion_material.set_shader_parameter("region_size_px", sprite.region_rect.size)
	sprite.material = explosion_material
	var dissolve_tween = create_tween()
	dissolve_tween.set_trans(Tween.TRANS_LINEAR)
	dissolve_tween.tween_method(
		_set_pixel_explosion_progress.bind(explosion_material),
		0.0,
		1.0,
		PIXEL_EXPLOSION_DURATION
	)
	dissolve_tween.tween_callback(func(): sprite.visible = false)

func _set_pixel_explosion_progress(progress: float, explosion_material: ShaderMaterial):
	explosion_material.set_shader_parameter("progress", progress)
	death_light.energy = maxf(sin(progress * PI), 0.0) * 1.8

func add_hit_effect(effect: Node2D):
	hit_effects.add_child(effect)
	board.configure_billboard_particles(effect)

func _flash_on_hit():
	if hit_flash_tween != null && hit_flash_tween.is_valid():
		hit_flash_tween.kill()
	sprite.self_modulate = HIT_FLASH_COLOR
	hit_flash_tween = create_tween()
	hit_flash_tween.set_trans(Tween.TRANS_QUAD)
	hit_flash_tween.set_ease(Tween.EASE_OUT)
	hit_flash_tween.tween_property(sprite, "self_modulate", Color.WHITE, HIT_FLASH_DURATION)

func _update_damage_smoke(health_percent: float, delta: float):
	if !alive || health_percent >= SMOKE_START_HEALTH_PERCENT:
		smoke_spawn_timer = 0.0
		return
	var damage_severity = clampf(
		(SMOKE_START_HEALTH_PERCENT - health_percent) / SMOKE_START_HEALTH_PERCENT,
		0.0,
		1.0
	)
	smoke_spawn_timer -= delta
	if smoke_spawn_timer > 0.0:
		return
	var intensity = smoothstep(0.0, 1.0, damage_severity)
	var spawn_interval = lerpf(0.36, 0.055, intensity)
	smoke_spawn_timer = spawn_interval * randf_range(0.82, 1.18)
	_spawn_damage_smoke_puff(intensity)

func _spawn_damage_smoke_puff(intensity: float):
	var billboard_layer = get_tree().get_first_node_in_group("billboard_layer") as Node2D
	if billboard_layer == null:
		return
	var puff = EnemySmokePuff.new()
	billboard_layer.add_child(puff)
	var spawn_screen_position = get_hit_screen_position() + Vector2(
		randf_range(-5.0, 5.0),
		randf_range(-7.0, -2.0)
	)
	var spawn_world_position = board.screen_to_world_position(spawn_screen_position)
	var puff_velocity = Vector2(randf_range(-3.0, 3.0), randf_range(-11.0, -6.0))
	var puff_lifetime = randf_range(0.85, 1.4)
	var puff_scale = randf_range(0.07, lerpf(0.11, 0.18, intensity))
	puff.setup(
		board,
		DAMAGE_SMOKE_TEXTURE,
		spawn_world_position,
		puff_velocity,
		puff_lifetime,
		puff_scale
	)

func _remove_billboard():
	if is_instance_valid(visual_billboard):
		visual_billboard.queue_free()
	if is_instance_valid(shadow_billboard):
		shadow_billboard.queue_free()

func sync_billboard():
	board.update_billboard(shadow_billboard, global_position)
	var shadow_offset = FLYING_SHADOW_OFFSET if flying else NORMAL_SHADOW_OFFSET
	shadow_billboard.position += shadow_offset * shadow_billboard.scale
	shadow_billboard.z_index -= 1
	board.update_billboard(visual_billboard, global_position)
	if flying:
		# Navigation, collisions, and the shadow remain on the ground path. Only
		# the upright enemy presentation is lifted into the air.
		visual_billboard.position.y -= FLYING_VISUAL_HEIGHT * visual_billboard.scale.y

func get_hit_screen_position() -> Vector2:
	return sprite.get_global_transform_with_canvas() * sprite.offset

func get_click_screen_position() -> Vector2:
	# BillboardLayer coordinates already match Viewport mouse coordinates. Using
	# get_global_transform_with_canvas() applies the canvas/stretch transform a
	# second time and makes the clickable area miss the displayed enemy.
	return sprite.get_global_transform() * sprite.offset

func get_hit_world_position() -> Vector2:
	return board.screen_to_world_position(get_hit_screen_position())

func get_click_radius_screen() -> float:
	var sprite_size = sprite.region_rect.size if sprite.region_enabled else sprite.texture.get_size()
	var local_radius = maxf(sprite_size.x, sprite_size.y) * 0.5
	return local_radius * visual_billboard.scale.x

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	if !alive:
		return
	velocity = safe_velocity
	move_and_slide()

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		Events.enemy_selected.emit(self)
