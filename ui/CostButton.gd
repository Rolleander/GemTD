extends Button

class_name CostButton

enum CostType{
	MONEY,
	ROLLS
}
enum EnabledType{
	BUILDING,
	WAVE,
	BOTH
}
@export var type = CostType.MONEY 
@export var enabled_type = EnabledType.BUILDING 
@export var cost : int = 0
@export var sprite : Sprite2D = null

@onready var panel = $Panel
@onready var c_icon_m = $Panel/IconM 
@onready var c_icon_r = $Panel/IconR 
@onready var c_label = $Panel/Label as Label

func _ready():
	if sprite != null:
		add_child(sprite)
		sprite.centered = true
		sprite.position.x = 30
		sprite.position.y = 30
		move_child(sprite, 0)
	c_icon_m.visible = false
		
func _update_label(value):
	c_label.text = str(cost)
	if value >= cost:
		c_label.label_settings.font_color = Color.WHITE
		if enabled_type == EnabledType.BOTH:
			disabled = false
		elif  enabled_type == EnabledType.BUILDING && Game.construction_phase:		
			disabled = false
		elif enabled_type == EnabledType.WAVE 	 && !Game.construction_phase:
			disabled = false
	else :
		c_label.label_settings.font_color = Color.DARK_RED	
		disabled = true	
		
func _update_panel():	
	c_icon_m.visible = type == CostType.MONEY
	c_icon_r.visible = type == CostType.ROLLS
	if type == CostType.MONEY:
		_update_label(Game.money)
	else:	 	
		_update_label(Game.remaining_placements)
		
func _process(delta):
	panel.visible = cost > 0
	if panel.visible:
		_update_panel()

func _on_pressed():
	if cost<=0:
		return
	if type == CostType.MONEY:
		Game.money -= cost
	else:
		Game.remaining_placements -= cost	
