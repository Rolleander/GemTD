extends Node

var construction_phase = true
var placements_per_round = 5
var remaining_placements = placements_per_round
var free_rerolls = 0
var reroll_count = 0
var wave = Wave.new("")
var money = 1000
var selected_gem: Gem
var selected_enemy: Enemy
var gem_chances: GemChances = GemChances.new()
var lives = 10
var path_length = 0

func _ready():
	Engine.time_scale = 1.5
	add_child(wave)
	Events.gem_selected.connect(_update_selection)
	Events.wave_ended.connect(_wave_ended)
	Events.enemy_killed.connect(_enemy_killed)
	Events.enemy_selected.connect(_update_selection)
	Events.enemy_reached_end.connect(_enemy_reached_end)
	
func finish_building():
	BuffUtils.update_tower_buffs()
	construction_phase = false
	wave.start_wave()

func gain_money(amount: int, location: Vector2):
	money += amount
	Events.overlay_text(
		location,
		"+" + str(amount),
		Color.GOLD,
		25
	)

func _enemy_killed(enemy: Enemy, killer: Gem):
	gain_money(enemy.money, enemy.get_hit_world_position())

func _enemy_reached_end(enemy: Enemy):
	lives -= 1
	if lives <= 0:
		_game_over()

func placed_gem(gem: Gem):
	gem.under_construction = true
	gem.remove_from_group("gems")
	gem.add_to_group("building")
	BuffUtils.update_tower_buffs()
	CombinationsCheck.check()
	_update_selection(gem)
	Events.gem_selected.emit(gem)

func _wave_ended():
	if lives <= 0:
		return
	_start_building()

func _start_building():
	reroll_count = 0
	construction_phase = true
	remaining_placements = placements_per_round
	Events.building_phase_started.emit()
	gem_chances.reset_on_turn()
	
func get_enemies():
	return get_tree().get_first_node_in_group("enemies_node").get_children() as Array[Enemy]
	
func get_gems():
	return get_tree().get_nodes_in_group("gems") as Array[Gem]

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
	if selected_gem != null:
		selected_gem.selection.visible = false
		selected_gem.range_ring.visible = false
		selected_gem = null
		for menu in get_tree().get_nodes_in_group("BuildMenu"):
			menu.visible = false
	if is_instance_valid(selected_enemy):
		selected_enemy.selection.visible = false
	selected_enemy = null
	Events.unselect.emit()

func reselect():
	if selected_gem != null:
		Events.gem_selected.emit(selected_gem)

func _game_over():
	for e in Game.get_enemies():
		e.kill()
