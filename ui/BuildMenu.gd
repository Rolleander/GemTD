extends Panel

@onready var downgrade = $HBoxContainer/Downgrade
@onready var fusion2 = $HBoxContainer/Fusion2
@onready var fusion4 = $HBoxContainer/Fusion4
@onready var combine = $HBoxContainer/Combine
@onready var reroll = $HBoxContainer/Reroll

var combos = []

func _ready():
	Events.wave_started.connect(func(): visible = false)
	Events.gem_selected.connect(_open)
	Events.unselect.connect(func(): visible = false)

func _open(gem : Gem):
	visible = gem.is_in_group("building") && !gem.rock
	if visible:
		combos = CombinationsCheck.check(get_tree().get_nodes_in_group("building"))
		downgrade.disabled =  gem.quality == 0
		fusion2.disabled = true
		fusion4.disabled = true
		reroll.disabled  = Game.remaining_placements == 0
		for c in combos:
			if c.gems.has(gem):
				if c is GemFusion:
					if c.fusion_size == 2:
						fusion2.disabled = false
					if c.fusion_size == 4:
						fusion4.disabled = false

func _end_building(keep_gem : Gem):
	var building = get_tree().get_nodes_in_group("building")
	for gem in building:
		if gem != keep_gem:
			gem.activate(false)
	keep_gem.activate(true)
	BuffUtils.update_tower_buffs()
	Events.gem_selected.emit(keep_gem)
	Game.finish_building()	

func _on_keep_pressed():
	var selected_gem = Game.selected_object
	if Game.construction_phase:
		var building = get_tree().get_nodes_in_group("building")
		if !building.has(selected_gem):
			return
		_end_building(selected_gem)

func _on_downgrade_pressed():
	var selected_gem = Game.selected_object
	selected_gem.init_basic_gem(selected_gem.type, selected_gem.quality -1)
	_end_building(selected_gem)

func _on_fusion_2_pressed():
	var selected_gem = Game.selected_object
	for c in combos:
		if c.gems.has(selected_gem):
			if c is GemFusion && c.fusion_size == 2:				
				_end_building(c.fuse(selected_gem))

func _on_fusion_4_pressed():
	var selected_gem = Game.selected_object
	for c in combos:
		if c.gems.has(selected_gem):
			if c is GemFusion && c.fusion_size == 4:				
				_end_building(c.fuse(selected_gem))


func _on_combine_pressed():
	pass # Replace with function body.


func _on_reroll_pressed():
	if Game.remaining_placements > 0:
		var selected_gem = Game.selected_object as Gem
		selected_gem.init_basic_gem(Game.gem_chances.get_random_type(), Game.gem_chances.get_random_quality())
		Game.placed_gem(selected_gem)
	
