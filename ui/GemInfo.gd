extends Panel

@onready var name_label = $Name

func _ready():
	Events.gem_selected.connect(_open)
	Events.unselect.connect(func(): visible = false)

func _open(gem : Gem):
	visible =true
	name_label.text = gem.gem_name
