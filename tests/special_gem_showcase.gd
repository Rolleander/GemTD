extends Node

const GEM_SCENE = preload("res://gems/gem.tscn")
const ENEMY_SCENE = preload("res://tests/showcase_enemy.tscn")

@export var special_gem_scene: PackedScene = preload("res://gems/special/brimstone.tscn")
@export var template_name: StringName = &"base"
@export var gem_position = Vector2(600.0, 360.0)
@export var enemy_grid_offset = Vector2(4.0, 0.0)
@export var enemy_health = 10000000.0

@onready var board = $Board as Board
@onready var reload_button = $ShowcaseControls/ReloadButton as Button

var showcase_gem: Gem
var showcase_enemy: Enemy
var reload_in_progress = false

func _ready():
	# Let the instanced board finish registering its world and billboard groups.
	await get_tree().process_frame
	Game.money = 10000
	_configure_showcase_state()
	showcase_gem = _create_special_gem()
	showcase_enemy = _create_stationary_enemy()
	_center_camera()
	_start_showcase_wave()


func _configure_showcase_state():
	#Game.construction_phase = false
	board.camera.edge_scrolling_enabled = false
	board.get_node("WorldPerspective/Marker").visible = false
	var board_ui = board.get_node_or_null("board_ui") as CanvasLayer
	if board_ui != null:
		board_ui.visible = true

func _start_showcase_wave():
	Game.wave.alive = 1
	Game.wave.spawned = 1
	Game.wave.spawn_target = 1
	Events.wave_started.emit()

func _center_camera():
	var enemy_position = gem_position + enemy_grid_offset * Globals.GRID_SIZE
	board.camera.position = gem_position.lerp(enemy_position, 0.5)
	board.camera.reset_smoothing()

func _create_special_gem() -> Gem:
	if special_gem_scene == null:
		push_error("Select a special gem scene for the showcase.")
		return null

	var gem = GEM_SCENE.instantiate() as Gem
	gem.position = gem_position
	board.path_map.block_path(gem_position)
	gem.under_construction = false
	board.maze.add_child(gem)
	gem.add_to_group("gems")
	gem.selection.visible = false
	gem.range_ring.visible = false
	gem.get_node("BuildingRing").hide()

	var special_scene = special_gem_scene.instantiate() as SpecialGemScene
	if special_scene == null:
		push_error("The selected scene must extend SpecialGemScene.")
		gem.queue_free()
		return null

	var settings = _find_special_gem_settings(special_gem_scene)
	if settings != null:
		gem.gem_name = settings.name
		special_scene.setup(gem, settings)
	else:
		# Rendering and attacks can still be tested for an unregistered scene.
		# Only resource-backed tier metadata will be unavailable.
		special_scene.gem = gem
		special_scene.install_template()

	if template_name != &"base":
		special_scene.install_template(template_name)
	Events.gem_selected.emit(gem)
	return gem

func _find_special_gem_settings(scene: PackedScene) -> SpecialGem:
	for settings in Globals.get_special_gems():
		if settings.scene == scene:
			return settings
		if settings.scene != null && settings.scene.resource_path == scene.resource_path:
			return settings
	return null

func _create_stationary_enemy() -> Enemy:
	var enemy_position = gem_position + enemy_grid_offset * Globals.GRID_SIZE
	var enemy = ENEMY_SCENE.instantiate() as Enemy
	enemy.position = enemy_position
	enemy.max_health = enemy_health
	enemy.health.value_set(enemy_health)
	enemy.speed.value_set(0.0)
	enemy.spawning = false
	board.enemies.add_child(enemy)
	# Reapply after _ready so the fixture owns the final combat values regardless
	# of defaults stored in the base enemy scene.
	enemy.max_health = enemy_health
	enemy.health.value_set(enemy_health)
	enemy.speed.value_set(0.0)
	enemy.navigation.avoidance_enabled = false
	enemy.velocity = Vector2.ZERO
	enemy.set_flying(false)
	return enemy

func _on_reload_button_pressed():
	if reload_in_progress || special_gem_scene == null:
		return
	reload_in_progress = true
	reload_button.disabled = true

	var scene_path = special_gem_scene.resource_path
	var reloaded_scene = ResourceLoader.load(
		scene_path,
		"PackedScene",
		ResourceLoader.CACHE_MODE_REPLACE_DEEP
	) as PackedScene
	if reloaded_scene == null:
		push_error("Could not reload special gem scene: " + scene_path)
		reload_button.disabled = false
		reload_in_progress = false
		return
	special_gem_scene = reloaded_scene

	if is_instance_valid(showcase_gem):
		if Game.selected_gem == showcase_gem:
			Game.clear_selection()
		showcase_gem._destroy_attack()
		showcase_gem.queue_free()
		await get_tree().process_frame

	showcase_gem = _create_special_gem()
	if is_instance_valid(showcase_gem) && is_instance_valid(showcase_gem.attack):
		showcase_gem.attack.active = true

	reload_button.disabled = false
	reload_in_progress = false
	Game.money = 10000
