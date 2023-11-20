extends VBoxContainer

@onready var gemLevel = $HBoxContainer/GemLevel
@onready var upgrade_button = $HBoxContainer/Upgrade as CostButton

func _ready():
	_update_level()

func _upgrade_allowed() -> bool:
	return Game.gem_chances.level <7 

func _on_upgrade_pressed():
	Game.gem_chances.inc_level()
	_update_level()

func _update_level():
	var cost = Game.gem_chances.get_upgrade_cost()
	gemLevel.text = str(Game.gem_chances.level+1)
	if _upgrade_allowed():
		upgrade_button.cost = Game.gem_chances.get_upgrade_cost()
	else: 
		upgrade_button.visible = false
