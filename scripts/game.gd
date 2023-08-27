extends Node

const PLACEMENTS_PER_ROUND = 15
const ENEMIES = 10

var construction_phase = true
var remaining_placements = PLACEMENTS_PER_ROUND
var wave = 0
var alive = 0
var spawn_target = 0
var spawned = 0
var selected_object
var spawn_timer = Timer.new()
var gem_chances : GemChances = GemChances.new()
var build_menu

func _ready():
	Events.enemy_killed.connect(_enemy_killed)
	Events.gem_selected.connect(_update_selection)
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_spawn_enemy)

func finish_building():
	#var maze = get_tree().get_first_node_in_group("maze_node")
	BuffUtils.update_tower_buffs()
	construction_phase = false
	_start_wave()

func _start_wave():
	spawned = 0
	spawn_target += 1
	spawn_timer.start(0.3)
	Events.emit_signal("wave_started")

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

func _spawn_enemy():
	var enemies = get_tree().get_first_node_in_group("enemies_node")
	var enemy = preload("res://scenes/enemy.tscn").instantiate() as Enemy
	enemy.waypoints = get_tree().get_first_node_in_group("waypoints").get_children()
	enemy.position = get_tree().get_first_node_in_group("spawn_point").position
	enemies.add_child(enemy)
	alive +=1
	spawned += 1
	enemy.set_flying(alive % 2 == 1)
	Events.emit_signal("enemy_spawned", enemy)
	if spawned == spawn_target:
		spawn_timer.stop()
				
func _enemy_killed(enemy: Enemy, attack: Attack):
	alive-=1
	if alive == 0:
		_wave_ended()	

func _wave_ended():
	Events.emit_signal("wave_ended")
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
		for menu in get_tree().get_nodes_in_group("BuildMenu"):
			menu.visible = false		
		Events.unselect.emit()


	
