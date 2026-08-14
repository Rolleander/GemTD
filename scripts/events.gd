extends Node

signal building_phase_started()
signal wave_started()
signal wave_ended()
signal unselect()
signal field_clicked(location: Vector2)
signal gem_selected(gem: Gem)
signal enemy_selected(enemy: Enemy)
signal enemy_spawned(enemy: Enemy)
signal enemy_killed(enemy: Enemy, killer: Gem)
signal enemy_reached_end(enemy: Enemy)


@onready var overlay_text_scene = preload("res://board/overlay_text.tscn")

func delayed(callable: Callable, delay: float):
	get_tree().create_timer(delay, false).connect("timeout", callable)

func delayed_set(target, propertyName, delay, value):
	get_tree().create_timer(delay, false).connect("timeout", target.set.bind(propertyName, value))

func delayed_destroy(target: Node2D, delay: float):
	delayed(func(): target.queue_free(), delay)

func overlay_text(
	position: Vector2,
	text: String,
	color: Color = Color(1.0, 0.313726, 0.160784, 1.0),
	font_size: int = 30,
):
	var instance = overlay_text_scene.instantiate()
	instance.text = text
	instance.text_color = color
	instance.font_size = font_size
	instance.world_position = position
	instance.screen_billboard = true
	var board = get_tree().get_first_node_in_group("board") as Board
	var billboard_layer = get_tree().get_first_node_in_group("billboard_layer") as Node2D
	billboard_layer.add_child(instance)
	instance.board = board
	instance.sync_billboard()

func screen_text(
	text: String,
	color: Color = Color(1.0, 0.313726, 0.160784, 1.0),
	font_size: int = 30,
	delay = 3.0,
	offset = Vector2(0, 0)
):
	var screen_text_layer = get_tree().get_first_node_in_group("ScreenText") as Control
	if screen_text_layer == null:
		push_error("ScreenText UI layer was not found.")
		return
	var instance = overlay_text_scene.instantiate()
	instance.text = text
	instance.text_color = color
	instance.font_size = font_size
	instance.delay = delay
	screen_text_layer.add_child(instance)
	instance.position = Vector2.ZERO + offset
