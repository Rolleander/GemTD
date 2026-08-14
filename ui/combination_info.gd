extends Panel

class_name CombinationInfo


@export var gem = SpecialGem

@onready var container = $VBoxContainer
@onready var name_label = $VBoxContainer/HBoxContainer/Name
@onready var recipe_label = $Recipe

func _ready():
	for i in gem.recipe.size():
		var recipe = gem.recipe[i]
		var gem_name = Utils.get_basic_gem_name(recipe.type, recipe.quality)
		var entry = preload("res://ui/recipe_entry.tscn").instantiate()
		var label = entry.find_child("Label") as Label
		label.text = gem_name
		if i < gem.recipe.size() - 1:
			label.text += " +"
		name_label.text = gem.name
		label.add_theme_color_override("font_color", Color.GREEN if _has_gem(recipe) else Color.GRAY)
		container.add_child(entry)

func _has_gem(id: BasicGemId):
	for gem in Game.get_gems():
		if !gem.special_combination && !gem.rock && gem.type == id.type && gem.quality == id.quality:
			return true
	return false
