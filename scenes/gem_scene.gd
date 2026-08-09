extends Gem

const CRYSTAL_SHADER = preload("res://resources/shaders/gem_crystal.gdshader")
const SPARKLE_SHADER = preload("res://resources/shaders/gem_sparkle.gdshader")

@onready var static_body = $StaticBody2D
@onready var comb_animation = $CombineRing/AnimationPlayer as AnimationPlayer
@onready var dmg_label = $DmgLabel

var active_combo : GemCombine = null
var glow_phase: float = 0.0
var base_light_energy: float = 0.0
var base_light_texture_scale: float = 0.0
var glow_quality_strength: float = 0.0

func _ready():
	super()
	static_body.input_event.connect(_on_static_body_2d_input_event)
	$CombineRing.hide()

func show_combine(combo : GemCombine):
	if active_combo == null || combo.gems.size() != active_combo.gems.size():
		comb_animation.play("combine_ring")		
	active_combo = combo
	$CombineRing.show()

func hide_combine():
	active_combo = null
	$CombineRing.hide()
	comb_animation.stop()

func make_rock():
	super()
	hide_combine()
	$PointLight2D.visible = false

func _process(delta: float) -> void:
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

func init_basic_gem(type : GemType, quality : GemQuality):
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
	var atk = type_info.attack.instantiate()
	_init_attack_stats(atk)
	set_attack(atk)
	var label_text = ""
	gem_name = ""
	if quality_info.label != null && !quality_info.label.is_empty():
		label_text += quality_info.label +"\n"
		gem_name +=quality_info.label+" "
	label_text += type_info.label
	gem_name +=  type_info.label
	label.label_settings = label.label_settings.duplicate()
	label.label_settings.font_color =  type_info.color.lightened(0.5)
	label.text = label_text

func _init_attack_stats(attack : Attack):
	var index = type * 6 + quality
	var stats = preload("res://resources/standard_gems.csv").records[index]	
	attack.damage = stats.Damage
	attack.attack_delay = stats.Speed
	attack.attack_range = stats.Range	
	attack.attack_scale += quality *.1

func _on_static_body_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		Events.emit_signal("gem_selected",self)
		
