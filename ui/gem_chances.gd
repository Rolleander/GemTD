extends Panel

class_name GemChancesInfo

@onready var chipped = $MarginContainer/VBoxContainer/GridContainer/ChippedChance as Label
@onready var flawed = $MarginContainer/VBoxContainer/GridContainer/FlawedChance as Label
@onready var normal = $MarginContainer/VBoxContainer/GridContainer/NormalChance as Label
@onready var flawless = $MarginContainer/VBoxContainer/GridContainer/FlawlessChance as Label
@onready var perfect = $MarginContainer/VBoxContainer/GridContainer/PerfectChance as Label

func _ready():
	update_labels()

func update_labels():
	var chances = Globals.get_roll_chances(Game.gem_chances.level)
	_set_chance_label(chipped, chances.chipped)
	_set_chance_label(flawed, chances.flawed)
	_set_chance_label(normal, chances.normal)
	_set_chance_label(flawless, chances.flawless)
	_set_chance_label(perfect, chances.perfect)

func _set_chance_label(label: Label, chance: int):
	label.text = str(chance) + "%"
	label.add_theme_color_override("font_color", Color.CYAN if chance > 0 else Color.DARK_GRAY.darkened(0.3))
