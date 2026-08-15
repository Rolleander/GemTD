extends Button

class_name CostButton

signal action_pressed

enum CostType {
	MONEY,
	PLACINGS,
	ROLLS
}
enum EnabledType {
	BUILDING,
	WAVE,
	BOTH
}
@export var type = CostType.MONEY
@export var enabled_type = EnabledType.BUILDING
@export var cost: int = 0

@onready var panel = $Panel
@onready var c_icon_m = $Panel/IconM
@onready var c_icon_r = $Panel/IconR
@onready var c_icon_p = $Panel/IconP
@onready var c_label = $Panel/Label as Label

func _ready():
	c_icon_m.visible = false
	c_icon_r.visible = false
	c_icon_p.visible = false
		
func _update_label(value):
	c_label.text = str(cost)
	if value >= cost:
		c_label.label_settings.font_color = Color.WHITE
		if enabled_type == EnabledType.BOTH:
			disabled = false
		elif enabled_type == EnabledType.BUILDING && Game.construction_phase:
			disabled = false
		elif enabled_type == EnabledType.WAVE && !Game.construction_phase:
			disabled = false
	else:
		c_label.label_settings.font_color = Color.RED
		disabled = true
		
func _update_panel():
	c_icon_m.visible = type == CostType.MONEY
	c_icon_r.visible = type == CostType.ROLLS
	c_icon_p.visible = type == CostType.PLACINGS
	if type == CostType.MONEY:
		_update_label(Game.money)
	elif type == CostType.PLACINGS:
		_update_label(Game.remaining_placements)
	else:
		_update_label(Game.free_rerolls)
		
func _process(delta):
	panel.visible = cost > 0
	if panel.visible:
		_update_panel()

func _on_pressed():
	if cost > 0:
		if type == CostType.MONEY:
			Game.money -= cost
		elif type == CostType.PLACINGS:
			Game.remaining_placements -= cost
		else:
			Game.free_rerolls -= cost
	action_pressed.emit()
