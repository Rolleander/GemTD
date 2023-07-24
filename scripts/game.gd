extends Node

const PLACEMENTS_PER_ROUND = 5
const ENEMIES = 10

var construction_phase = true
var remaining_placements = PLACEMENTS_PER_ROUND
var wave = 0
var alive = 0
var spawn_target = 0
var spawned = 0
var selected_object
var spawn_timer = Timer.new()

func _ready():
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_spawn_enemy)

func _finish_building():
	#var maze = get_tree().get_first_node_in_group("maze_node")
	construction_phase = false
	_start_wave()

func _start_wave():
	spawned = 0
	spawn_target += 1
	spawn_timer.start(0.3)

func placed_gem(gem: Gem):
	gem.selected.connect(_selected_gem)
	Game.remaining_placements-=1	
	_update_selection(gem)
	
func _start_building():
	construction_phase = true
	remaining_placements = PLACEMENTS_PER_ROUND
	
func get_enemies() :
	return get_tree().get_first_node_in_group("enemies_node").get_children() 
	
func get_gems():
	return get_tree().get_first_node_in_group("gems").get_children() 

func _spawn_enemy():
	var enemies = get_tree().get_first_node_in_group("enemies_node")
	var enemy = preload("res://scenes/enemy.tscn").instantiate() as Enemy
	enemy.waypoints = get_tree().get_first_node_in_group("waypoints").get_children()
	enemy.position = get_tree().get_first_node_in_group("spawn_point").position
	enemy.enemy_died.connect(_enemy_died)
	enemies.add_child(enemy)
	alive +=1
	spawned += 1
	if spawned == spawn_target:
		spawn_timer.stop()
	
func _selected_gem(selected_gem : Gem):
	_update_selection(selected_gem)
	if construction_phase && remaining_placements <= 0:
		var building = get_tree().get_nodes_in_group("building")
		if !building.has(selected_gem):
			return
		for gem in building:
			gem.activate(gem == selected_gem)
		_finish_building()						

func _enemy_died(enemy: Enemy):
	alive-=1
	if alive == 0:
		_start_building()

func _update_selection(object):
	selected_object = object
	object.selection.visible = true 
	if !object.rock: 
		object.range_ring.visible = true
	for gem in get_tree().get_first_node_in_group("maze_node").get_children():
		if gem != object:
			gem.selection.visible = false
			gem.range_ring.visible = false

func clear_selection():
	if selected_object !=null:
		selected_object.selection.visible = false
		selected_object.range_ring.visible = false
		selected_object= null
