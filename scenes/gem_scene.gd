extends Gem

@onready var static_body = $StaticBody2D

func _ready():
	super()
	static_body.input_event.connect(_on_static_body_2d_input_event)

func init_basic_gem(type : GemType, quality : GemQuality):
	add_to_group("building")
	self.type = type
	self.quality = quality 
	under_construction = true
	var scale = 1 + (quality * 0.3)
	glow.transform = glow.transform.scaled(Vector2(scale, scale ))
	var type_info = Globals.get_gem_info(type)
	var quality_info = Globals.get_quality_info(quality)
	var render = quality_info.scene.instantiate()
	render.region_rect.position = Vector2(type * render.region_rect.size.x, 0)
	for n in graphic.get_children():
		graphic.remove_child(n)
	graphic.add_child(render)
	_set_attack(type_info.attack.instantiate())
	var label_text = ""
	gem_name = ""
	if quality_info.label != null:
		label_text += quality_info.label +"\n"
		gem_name +=quality_info.label+" "
	label_text += type_info.label
	gem_name +=  type_info.label
	label.label_settings = label.label_settings.duplicate()
	label.label_settings.font_color =  type_info.color.lightened(0.5)
	label.text = label_text

func _on_static_body_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		Events.emit_signal("gem_selected",self)
		
