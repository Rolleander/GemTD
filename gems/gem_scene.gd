extends Gem

class_name GemScene

const CRYSTAL_SHADER = preload("res://resources/shaders/gem_crystal.gdshader")
const SPARKLE_SHADER = preload("res://resources/shaders/gem_sparkle.gdshader")

@onready var static_body = $StaticBody2D
@onready var comb_animation = $CombineRing/AnimationPlayer as AnimationPlayer
@onready var dmg_label = $Billboard/DmgLabel

var glow_phase: float = 0.0
var base_light_energy: float = 0.0
var base_light_texture_scale: float = 0.0
var glow_quality_strength: float = 0.0
var special_graphic_lights = []

func _ready():
	process_priority = 10
	super()
	board.attach_billboard(billboard)
	board.update_billboard(billboard, global_position)
	tree_exiting.connect(_remove_billboard)
	static_body.input_event.connect(_on_static_body_2d_input_event)
	$CombineRing.hide()

func _remove_billboard():
	_clear_special_graphic_lights()
	if is_instance_valid(billboard):
		billboard.queue_free()

func sync_billboard():
	board.update_billboard(billboard, global_position)

func refresh_billboard_effects():
	board.configure_billboard_particles(billboard)
	_extract_special_graphic_lights()

func disable_default_glow():
	super()
	base_light_energy = 0.0
	$PointLight2D.visible = false

func _extract_special_graphic_lights():
	_clear_special_graphic_lights()
	for node in graphic.find_children("*", "PointLight2D", true, false):
		var world_light = node as PointLight2D
		if world_light == null:
			continue
		var anchor = world_light.get_parent() as Node2D
		if anchor == null:
			continue
		var local_transform = world_light.transform
		var billboard_light = Sprite2D.new()
		var billboard_material = CanvasItemMaterial.new()
		billboard_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		billboard_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		billboard_light.material = billboard_material
		anchor.add_child(billboard_light)
		billboard_light.transform = local_transform
		world_light.reparent(self, false)
		world_light.position = Vector2.ZERO
		special_graphic_lights.append({
			"world": world_light,
			"billboard": billboard_light,
			"local_transform": local_transform,
		})
	_sync_special_graphic_lights()

func _sync_special_graphic_lights():
	for entry in special_graphic_lights:
		var world_light = entry["world"] as PointLight2D
		var billboard_light = entry["billboard"] as Sprite2D
		if !is_instance_valid(world_light) || !is_instance_valid(billboard_light):
			continue
		var energy = maxf(world_light.energy, 0.0) * 0.25
		var light_color = world_light.color
		billboard_light.texture = world_light.texture
		billboard_light.transform = entry["local_transform"]
		billboard_light.scale *= world_light.texture_scale
		billboard_light.modulate = Color(
			light_color.r * energy,
			light_color.g * energy,
			light_color.b * energy,
			clampf(light_color.a * energy, 0.0, 1.0)
		)
		billboard_light.visible = world_light.visible && world_light.enabled

func _clear_special_graphic_lights():
	for entry in special_graphic_lights:
		var world_light = entry["world"] as PointLight2D
		var billboard_light = entry["billboard"] as Sprite2D
		if is_instance_valid(world_light):
			world_light.queue_free()
		if is_instance_valid(billboard_light):
			var parent = billboard_light.get_parent()
			if parent != null:
				parent.remove_child(billboard_light)
			billboard_light.free()
	special_graphic_lights.clear()

func get_attack_origin_screen_position() -> Vector2:
	var renders = graphic.find_children("*", "Sprite2D", true, false)
	if renders.is_empty():
		return billboard.position
	var render = renders[0] as Sprite2D
	return render.get_global_transform_with_canvas() * render.offset

func get_attack_origin_world_position() -> Vector2:
	var renders = graphic.find_children("*", "Sprite2D", true, false)
	if renders.is_empty():
		return global_position
	var render = renders[0] as Sprite2D
	var render_center = render.get_global_transform() * render.offset
	var local_origin = billboard.get_global_transform().affine_inverse() * render_center
	return global_position + local_origin

func update_level_visual():
	if rock || graphic.get_child_count() == 0:
		return
	var render = graphic.get_child(0) as Sprite2D
	if render == null:
		return
	var level_progress = clampf(float(level) / float(LevelUp.MAX_LEVEL), 0.0, 1.0)
	var size_multiplier = lerpf(1.0, 1.35, level_progress)
	var half_height = render.region_rect.size.y * 0.5
	render.scale = Vector2.ONE * size_multiplier
	render.offset.y = - half_height * (1.0 - 1.0 / size_multiplier) + (size_multiplier * 5.0) - 6.0

func show_combine(combo: GemCombine):
	#if available_combo == null || combo.gems.size() != available_combo.gems.size():
	comb_animation.play("combine_ring")
	available_combo = combo
	$CombineRing.show()

func hide_combine():
	available_combo = null
	$CombineRing.hide()
	comb_animation.stop()

func make_rock():
	super()
	hide_combine()
	$PointLight2D.visible = false

func activate_combination():
	super()
	hide_combine()

func _process(delta: float) -> void:
	sync_billboard()
	_sync_special_graphic_lights()
	if base_light_energy <= 0.0 || rock:
		return
	glow_phase += delta * lerpf(1.35, 1.7, glow_quality_strength)
	var pulse_wave: float = sin(glow_phase + sin(glow_phase * 0.31) * 0.42)
	var normalized_pulse: float = pulse_wave * 0.5 + 0.5
	var gem_light := $PointLight2D as PointLight2D
	gem_light.energy = base_light_energy * lerpf(0.55, 1.1, normalized_pulse)
	gem_light.texture_scale = base_light_texture_scale * lerpf(0.9, 1.03, normalized_pulse)

func init_glow(quality_level: int, color: Color) -> void:
	var quality_strength: float = float(quality_level) / float(GemQualityInfo.Quality.GREAT)
	glow_quality_strength = quality_strength
	var gem_light := $PointLight2D as PointLight2D
	gem_light.visible = true
	gem_light.color = color.lightened(0.12)
	base_light_energy = lerpf(0.28, 0.9, quality_strength)
	base_light_texture_scale = lerpf(0.18, 0.34, quality_strength)
	gem_light.energy = base_light_energy
	gem_light.texture_scale = base_light_texture_scale

	glow.visible = true
	glow.scale = Vector2.ONE * lerpf(0.14, 0.29, quality_strength)
	var glow_material := glow.material as ShaderMaterial
	var glow_random: float = randf()
	glow_phase = glow_random * TAU
	glow_material.set_shader_parameter("glow_color", color)
	glow_material.set_shader_parameter("quality", quality_strength)
	glow_material.set_shader_parameter("rand", glow_random)
	glow_material.set_shader_parameter("speed", lerpf(0.018, 0.045, quality_strength))
	glow_material.set_shader_parameter("energy", lerpf(0.2, 0.58, quality_strength))


func _apply_crystal_material(render: Sprite2D, quality_level: int, color: Color) -> void:
	var quality_strength: float = float(quality_level) / float(GemQualityInfo.Quality.GREAT)
	var crystal_material := ShaderMaterial.new()
	crystal_material.shader = CRYSTAL_SHADER
	crystal_material.set_shader_parameter("gem_color", color)
	crystal_material.set_shader_parameter("quality", quality_strength)
	crystal_material.set_shader_parameter("rand", randf())
	render.material = crystal_material

	var particles := render.get_node_or_null("GPUParticles2D") as GPUParticles2D
	if particles != null:
		particles.modulate = Color.WHITE
		particles.amount = maxi(particles.amount, 4 + quality_level * 4)
		var sparkle_material := ShaderMaterial.new()
		sparkle_material.shader = SPARKLE_SHADER
		sparkle_material.set_shader_parameter("sparkle_color", color.lightened(0.5))
		sparkle_material.set_shader_parameter("intensity", lerpf(0.62, 1.08, quality_strength))
		particles.material = sparkle_material

		var particle_process := particles.process_material.duplicate() as ParticleProcessMaterial
		particle_process.angle_min = -7.0
		particle_process.angle_max = 7.0
		particle_process.angular_velocity_min = -10.0
		particle_process.angular_velocity_max = 10.0
		particle_process.scale_min = lerpf(0.14, 0.2, quality_strength)
		particle_process.scale_max = lerpf(0.5, 0.88, quality_strength)
		particles.process_material = particle_process

func init_basic_gem(type: GemType, quality: GemQuality):
	self.type = type
	self.quality = quality
	var type_info = Globals.get_gem_info(type)
	var quality_info = Globals.get_quality_info(quality)
	var gem_color: Color = type_info.color.lightened(0.1)
	init_glow(int(quality), gem_color)
	var render: Sprite2D = quality_info.scene.instantiate()
	render.region_rect.position = Vector2(type * render.region_rect.size.x, 0)
	_apply_crystal_material(render, int(quality), gem_color)
	for n in graphic.get_children():
		graphic.remove_child(n)
		n.queue_free()
	graphic.add_child(render)
	refresh_billboard_effects()
	update_level_visual()
	var atk = type_info.attack.instantiate()
	_init_attack_stats(atk)
	set_attack(atk)
	var label_text = ""
	gem_name = ""
	if quality_info.label != null && !quality_info.label.is_empty():
		label_text += quality_info.label + "\n"
		gem_name += quality_info.label + " "
	label_text += type_info.label
	gem_name += type_info.label
	label.label_settings = label.label_settings.duplicate()
	label.label_settings.font_color = type_info.color.lightened(0.5)
	label.text = label_text

func _init_attack_stats(attack: Attack):
	var index = type * 6 + quality
	var stats = preload("res://resources/standard_gems.csv").records[index]
	attack.damage = stats.Damage
	attack.attack_delay = stats.Speed
	attack.attack_range = stats.Range
	attack.attack_scale += quality * .1

func _on_static_body_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		Events.emit_signal("gem_selected", self)
