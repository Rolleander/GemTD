extends Node

signal wave_started()
signal wave_ended()
signal gem_selected(gem : Gem)
signal enemy_spawned(enemy : Enemy)
signal enemy_killed(enemy: Enemy, attack: Attack)

func delayed(callable : Callable, delay : float):
	get_tree().create_timer(delay, false).connect("timeout", callable)

func delayed_set(target, propertyName, delay, value):
	get_tree().create_timer(delay, false).connect("timeout", target.set.bind(propertyName, value))
