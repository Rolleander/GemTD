extends Node2D

class_name SpecialGemScene

var gem: Gem
var recipe: SpecialGem

func install(gem: Gem):
	self.gem = gem
	var new_graphic := get_node_or_null("Graphic") as Node2D
	var new_attack := get_node_or_null("Attack") as Attack

	if new_graphic == null || new_attack == null:
		push_error("Special gem scene requires Graphic and Attack children.")
		return

	remove_child(new_graphic)
	remove_child(new_attack)

	for old_graphic in gem.graphic.get_children():
		gem.graphic.remove_child(old_graphic)
		old_graphic.queue_free()

	new_graphic.visible = true
	gem.special_combination = self
	gem.graphic.add_child(new_graphic)
	gem.refresh_billboard_effects()
	gem.set_attack(new_attack)

func init_menu(menu: GemMenu):
	pass
