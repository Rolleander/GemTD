extends Node

const PLACEMENTS_PER_ROUND = 5

var construction_phase = true
var remaining_placements = PLACEMENTS_PER_ROUND
var wave = Wave.new("")
var money = 0
var selected_gem : Gem
var selected_enemy : Enemy
var gem_chances : GemChances = GemChances.new()
var build_menu

func _ready():
	Engine.time_scale = 1.5
	add_child(wave)
	Events.gem_selected.connect(_update_selection)
	Events.wave_ended.connect(func(): _start_building())
	Events.enemy_killed.connect(_enemy_killed)
	Events.enemy_selected.connect(_update_selection)
	
func finish_building():
	#var maze = get_tree().get_first_node_in_group("maze_node")
	BuffUtils.update_tower_buffs()
	construction_phase = false
	wave.start_wave()

func _enemy_killed(enemy: Enemy, killer: Gem):
	money+=1

func placed_gem(gem: Gem):
	Game.remaining_placements-=1		
	BuffUtils.update_tower_buffs()
	_update_selection(gem)	
	Events.gem_selected.emit(gem)

func _start_building():
	construction_phase = true
	remaining_placements = PLACEMENTS_PER_ROUND
	
func get_enemies() :
	return get_tree().get_first_node_in_group("enemies_node").get_children() 
	
func get_gems():
	return get_tree().get_nodes_in_group("gems")

func _update_selection(object):
	if object is Gem:
		selected_gem = object
		if !object.rock: 
			object.range_ring.visible = true
		for gem in get_tree().get_first_node_in_group("maze_node").get_children():
			if gem != object:
				gem.selection.visible = false
				gem.range_ring.visible = false	
	elif object is Enemy:
		selected_enemy = object
		for enemy in get_enemies():
			if enemy != object:
				enemy.selection.visible = false
	object.selection.visible = true 

func clear_selection():
	if selected_gem !=null:
		selected_gem.selection.visible = false
		selected_gem.range_ring.visible = false
		selected_gem= null
		for menu in get_tree().get_nodes_in_group("BuildMenu"):
			menu.visible = false		
	Events.unselect.emit()

func reselect():
	if selected_gem != null:
		Events.gem_selected.emit(selected_gem)

	
