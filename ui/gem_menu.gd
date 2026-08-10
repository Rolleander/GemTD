extends Panel

@onready var combine = $HBoxContainer/Combine

var gem: Gem

func _ready():
	Events.gem_selected.connect(_open)
	Events.unselect.connect(func(): visible = false)


func _open(gem: Gem):
	self.gem = gem
	var is_board_gem := gem.is_in_group("gems") && !gem.is_in_group("building")
	visible = !gem.rock && !gem.under_construction && is_board_gem
	combine.visible = gem.available_combo != null

func _on_combine_pressed() -> void:
	gem.activate_combination()
