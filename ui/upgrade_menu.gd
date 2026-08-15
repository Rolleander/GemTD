extends Panel

@onready var upgrade_button = $HBoxContainer/Upgrade as CostButton
@onready var upgrade2_button = $HBoxContainer/Upgrade2 as CostButton

func _ready():
	_update_level()

func _upgrade_allowed() -> bool:
	return Game.gem_chances.level < 7

func _update_level():
	var cost = Game.gem_chances.get_upgrade_cost()
	if _upgrade_allowed():
		upgrade_button.cost = Game.gem_chances.get_upgrade_cost()
	else:
		UiUtils.hide_element(upgrade_button)

func _on_upgrade_pressed():
	Game.gem_chances.inc_level()
	_update_level()

func _on_upgrade_2_pressed():
	Game.placements_per_round += 1
	Game.remaining_placements += 1
	UiUtils.hide_element(upgrade2_button)
