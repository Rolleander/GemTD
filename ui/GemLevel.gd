extends VBoxContainer

@onready var gemLevel = $HBoxContainer/GemLevel
@onready var button = $HBoxContainer/Upgrage

func _ready():
	_update_level()

func _upgrade_allowed() -> bool:
	return Game.gem_chances.level <7 && Game.money >= Game.gem_chances.get_upgrade_cost()

func _on_upgrade_pressed():
	if _upgrade_allowed():
		Game.money-Game.gem_chances.get_upgrade_cost()
		Game.gem_chances.inc_level()
		_update_level()

func _update_level():
	var cost = Game.gem_chances.get_upgrade_cost()
	gemLevel.text = str(Game.gem_chances.level+1)+" Upgrade ("+str(cost)+")"
	
func _physics_process(delta):
	button.disabled = !_upgrade_allowed()
