extends Gem

@onready var static_body = $StaticBody2D

func _ready():
	init_random_gem()
	static_body.input_event.connect(_on_static_body_2d_input_event)

func init_random_gem():
	add_to_group("building")
	under_construction = true
	type = GemChances.get_random_type()
	quality = GemChances.get_random_quality()
	sprite.region_rect.position = Vector2(type * SPRITE_SIZE, quality * SPRITE_SIZE)
	var scale = 1 + (quality * 0.3)
	glow.transform = glow.transform.scaled(Vector2(scale, scale ))
	var type_info = Globals.get_gem_info(type)
	var quality_info = Globals.get_quality_info(quality)
	_set_attack(load("res://attacks/"+type_info.attack_scene+".tscn").instantiate())
	var label_text = ""
	if quality_info.label != null:
		label_text += quality_info.label +"\n"
	label_text += type_info.label
	label.text = label_text
	labelShadow.text = label_text
	label.modulate = type_info.color.lightened(0.5)

func _on_static_body_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		emit_signal("selected", self)
		
