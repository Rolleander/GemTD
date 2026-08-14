extends TileMap

class_name PathMap

var waypoints: Array[Vector2] = []

func block_path(position: Vector2, block = true):
	var x = int(position.x / Globals.GRID_SIZE)
	var y = int(position.y / Globals.GRID_SIZE)
	var tile = 1 if block else 0
	set_cell(0, Vector2i(x, y), 0, Vector2(tile, 0))
	set_cell(0, Vector2i(x - 1, y), 0, Vector2(tile, 0))
	set_cell(0, Vector2i(x, y - 1), 0, Vector2(tile, 0))
	set_cell(0, Vector2i(x - 1, y - 1), 0, Vector2(tile, 0))

func is_blocked(position: Vector2):
	return Utils.selection_tile_is(self, position, Vector2i(1, 0))

func placing_allowed(position: Vector2) -> bool:
	block_path(position)
	var valid = await _valid_path()
	block_path(position, false)
	return valid

func _valid_path() -> bool:
	var rid = get_navigation_map(0)
	force_update()
	await NavigationServer2D.map_changed
	for i in range(0, waypoints.size() - 1):
		var path = NavigationServer2D.map_get_path(rid, waypoints[i], waypoints[i + 1], true, 1)
		if path[path.size() - 1] != waypoints[i + 1]:
			return false
	return true

func calc_path_length() -> int:
	var rid = get_navigation_map(0)
	force_update()
	await NavigationServer2D.map_changed
	var length = 0.0
	for i in range(waypoints.size() - 1):
		var path: PackedVector2Array = NavigationServer2D.map_get_path(
			rid,
			waypoints[i],
			waypoints[i + 1],
			true,
			1
		)
		if path.is_empty() || !path[path.size() - 1].is_equal_approx(waypoints[i + 1]):
			return -1
		for point_index in range(1, path.size()):
			length += path[point_index - 1].distance_to(path[point_index])
	return length / Globals.GRID_SIZE
