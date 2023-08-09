extends Panel

@onready var name_label = $MarginContainer/Name
@onready var level_label = $MarginContainer/Level

func _ready():
	Events.gem_selected.connect(_open)
	Events.unselect.connect(func(): visible = false)

func _open(gem : Gem):
	visible =true
	name_label.text = gem.gem_name
	level_label.text = "Lv. "+str(gem.level)
