extends Panel

@onready var reroll = $HBoxContainer/Reroll


func _ready():
	Events.wave_started.connect(func(): visible = false)
	Events.gem_selected.connect(_open)

func _open(gem : Gem):
	visible = gem.rock && Game.construction_phase
	reroll.disabled  = Game.remaining_placements == 0
	
func _on_reroll_pressed():
	if Game.remaining_placements > 0:
		var selected_gem = Game.selected_object as Gem
		var position = selected_gem.position
		selected_gem.queue_free()
		var gem = preload("res://scenes/gem.tscn").instantiate()
		gem.position = position
		get_tree().get_first_node_in_group("maze_node").add_child(gem)
		gem.init_basic_gem(Game.gem_chances.get_random_type(), Game.gem_chances.get_random_quality())
		Game.placed_gem(gem)
