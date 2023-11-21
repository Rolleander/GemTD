extends Gem

@onready var static_body = $StaticBody2D
@onready var comb_animation = $CombineRing/AnimationPlayer as AnimationPlayer

var active_combo : GemCombine = null

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

func init_glow(scale : float, color : Color):
	glow.visible = true
	glow.scale= Vector2(scale,scale) * 0.25
	glow.material.set_shader_parameter("glow_color", color)
	glow.material.set_shader_parameter("rand", randf())
	glow.material.set_shader_parameter("speed", 0.03)
	glow.material.set_shader_parameter("energy", 0.7)

func init_basic_gem(type : GemType, quality : GemQuality):
	self.type = type
	self.quality = quality 
	var scale = 1 + (quality * 0.25)
	var type_info = Globals.get_gem_info(type)
	var quality_info = Globals.get_quality_info(quality)
	init_glow(scale,  type_info.color.lightened(0.1))
	var render = quality_info.scene.instantiate()
	render.region_rect.position = Vector2(type * render.region_rect.size.x, 0)
	for n in graphic.get_children():
		graphic.remove_child(n)
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
		
