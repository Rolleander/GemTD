extends Panel


@export var chancesInfo: GemChancesInfo
@onready var upgrade_button = $MarginContainer/LevelMenu/HBoxContainer/Upgrade as CostButton

var selected_gem_type = -1


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
	chancesInfo.update_labels()

func _on_upgrade_pressed():
	Game.gem_chances.inc_level()
	_update_level()

func _on_upgrade_2_pressed():
	Game.placements_per_round += 1
	Game.remaining_placements += 1

func _on_upgrade_3_pressed() -> void:
	var selection = get_tree().get_first_node_in_group("gem_type_selection") as GemTypeSelection
	selected_gem_type = await selection.select_type()
	var type = Globals.get_gem_info(selected_gem_type)
	Events.screen_text("Increased chance for " + type.label + " gems this turn", Color.LIGHT_GREEN, 50)
	Game.gem_chances.prefer_type = type.type


func _on_upgrade_4_pressed() -> void:
	pass # Replace with function body.


func _on_upgrade_5_pressed() -> void:
	pass # Replace with function body.
