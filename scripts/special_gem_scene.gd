extends Node2D

class_name SpecialGemScene

var gem: Gem
var recipe: SpecialGem
var tier = 0
var _upgrade_tiers = []

func install(gem: Gem, template_name: StringName = &"base"):
	self.gem = gem
	var template = get_node_or_null(NodePath(str(template_name))) as Node
	if template == null:
		push_error("Special gem template '%s' was not found." % template_name)
		return

	var new_graphic = template.get_node_or_null("Graphic") as Node2D
	var new_attack = template.get_node_or_null("Attack") as Attack

	if new_graphic == null || new_attack == null:
		push_error(
			"Special gem template '%s' requires Graphic and Attack children."
			% template_name
		)
		return

	template.remove_child(new_graphic)
	template.remove_child(new_attack)

	for old_graphic in gem.graphic.get_children():
		gem.graphic.remove_child(old_graphic)
		old_graphic.queue_free()

	new_graphic.visible = true
	gem.special_combination = self
	gem.graphic.add_child(new_graphic)
	gem.refresh_billboard_effects()
	gem.set_attack(new_attack)

func _change_gem_to(node_name: String):
	install(gem, node_name)
	BuffUtils.update_tower_buffs()
	Game.reselect()


func init_menu(menu: GemMenu):
	if tier >= _upgrade_tiers.size():
		return
	var upgrade_button = menu.register_action_button(_upgrade_tier)
	upgrade_button.cost = _upgrade_tiers[tier]["cost"]
	upgrade_button.text = "U"
	upgrade_button.tooltip_text = "Upgrade to " + _upgrade_tiers[tier]["name"]

func _init_upgrade_tier(name: String, cost: int):
	_upgrade_tiers.append({
		"name": name,
		"cost": cost
	})

func _upgrade_tier():
	gem.gem_name = _upgrade_tiers[tier]["name"]
	tier += 1
	_change_gem_to("upgrade" + str(tier))
