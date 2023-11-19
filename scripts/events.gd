extends Node

signal wave_started()
signal wave_ended()
signal unselect()
signal field_clicked(location : Vector2)
signal gem_selected(gem : Gem)
signal enemy_selected(enemy : Enemy)
signal enemy_spawned(enemy : Enemy)
signal enemy_killed(enemy: Enemy, killer: Gem)

@onready var overlay_text_scene = preload("res://scenes/overlay_text.tscn")

func delayed(callable : Callable, delay : float):
	get_tree().create_timer(delay, false).connect("timeout", callable)

func delayed_set(target, propertyName, delay, value):
	get_tree().create_timer(delay, false).connect("timeout", target.set.bind(propertyName, value))

func delayed_destroy(target : Node2D, delay : float):
	delayed(func(): target.queue_free(), delay)

func overlay_text(target : Node2D, text : String):
	var instance = overlay_text_scene.instantiate()
	instance.position = target.position
	instance.text = text
	get_tree().get_first_node_in_group("Effects").add_child(instance)
