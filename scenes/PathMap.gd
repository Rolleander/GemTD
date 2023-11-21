extends TileMap

class_name PathMap


func block_path(position : Vector2, block = true):
	var x =  int(position.x / Globals.GRID_SIZE )
	var y =  int(position.y / Globals.GRID_SIZE )
	var tile = 1  if block else 0
	set_cell(0, Vector2i(x,y), 0, Vector2( tile,0))
	set_cell(0, Vector2i(x-1,y), 0, Vector2( tile,0))
	set_cell(0, Vector2i(x,y-1), 0, Vector2( tile,0))
	set_cell(0, Vector2i(x-1,y-1), 0, Vector2( tile,0))

func is_blocked(position : Vector2):
	return Utils.selection_tile_is(self, position, Vector2i( 1,0))

func placing_allowed(position : Vector2,  path : Array) -> bool :
	block_path(position)
	var valid = await _valid_path(path)
	block_path(position, false)	
	return valid

func _valid_path(waypoints: Array) -> bool:
	var rid = get_navigation_map(0)
	force_update()
	await NavigationServer2D.map_changed
	for i in range(0, waypoints.size()-1):
		var path = NavigationServer2D.map_get_path(rid, waypoints[i], waypoints[i+1], true, 1)
		if path[path.size()-1] != waypoints[i+1]:			
			return false
	return true 
