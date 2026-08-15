extends Panel

@onready var reroll = $HBoxContainer/Reroll
@onready var remove = $HBoxContainer/Remove
var field_position: Vector2
var rock: Gem

func _ready():
	Events.wave_started.connect(func(): visible = false)
	Events.gem_selected.connect(_open)
	Events.field_clicked.connect(_open_field)
	Events.unselect.connect(func(): visible = false)

func _open(gem: Gem):
	visible = gem.rock
	UiUtils.hide_element(remove, false)
	field_position = gem.position
	rock = gem

func _open_field(position: Vector2):
	visible = Game.construction_phase
	UiUtils.hide_element(remove, true)
	field_position = position
	rock = null
	
func _on_reroll_pressed():
	if rock != null:
		rock.queue_free()
		var gem = preload("res://gems/gem.tscn").instantiate()
		gem.position = field_position
		get_tree().get_first_node_in_group("maze_node").add_child(gem)
		gem.init_basic_gem(Game.gem_chances.get_random_type(), Game.gem_chances.get_random_quality())
		Game.placed_gem(gem)
	else:
		var board = get_tree().get_first_node_in_group("board") as Board
		board.place_gem()

func _on_remove_pressed():
	rock.queue_free()
	var board = get_tree().get_first_node_in_group("board") as Board
	board.path_map.block_path(rock.position, false)
	Game.clear_selection()
