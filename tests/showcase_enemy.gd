extends Enemy

func _next_waypoint():
	# The showcase dummy never completes a route or emits enemy_reached_end.
	target = 0
	navigation.target_position = global_position + Vector2(Globals.GRID_SIZE, 0.0)

func _physics_process(delta: float):
	spawning = false
	velocity = Vector2.ZERO
	navigation.velocity = Vector2.ZERO
	if !alive:
		return

	health.update()
	speed.update()
	_update_slow_tint()
	armor.update()
	if health.value <= 0.0:
		_death(killer)
		return
	BuffUtils.progress_enemy_buffs(self, delta)
