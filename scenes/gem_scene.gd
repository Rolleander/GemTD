extends Gem

@onready var static_body = $StaticBody2D

func _ready():
	super()
	static_body.input_event.connect(_on_static_body_2d_input_event)

func init_basic_gem(type : GemType, quality : GemQuality):
	add_to_group("building")
	under_construction = true
	sprite.region_rect.position = Vector2(type * SPRITE_SIZE, quality * SPRITE_SIZE)
	var scale = 1 + (quality * 0.3)
	glow.transform = glow.transform.scaled(Vector2(scale, scale ))
	var type_info = Globals.get_gem_info(type)
	var quality_info = Globals.get_quality_info(quality)
	_set_attack(type_info.attack.instantiate())
	var label_text = ""
	if quality_info.label != null:
		label_text += quality_info.label +"\n"
	label_text += type_info.label
	label.text = label_text
	labelShadow.text = label_text
	label.modulate = type_info.color.lightened(0.5)

func _on_static_body_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		Events.emit_signal("gem_selected",self)
		
