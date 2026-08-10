extends SpecialGemScene

func init_menu(menu: GemMenu):
	var upgrade_button = menu.register_action_button(_upgrade)
	upgrade_button.cost = 25
	upgrade_button.text = "U"
	upgrade_button.tooltip_text = "Upgrade to PowerBubbler"

func _upgrade():
	print("upgrade")
