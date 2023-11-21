extends Node


func in_range(source : Node2D, target : Node2D, range : float, object_r : float = 0) -> bool:
	return source.global_position.distance_to(target.global_position) <= (range * Globals.TILE_SIZE)/ 2 + object_r

func selection_tile_is(map : TileMap, position : Vector2, tile : Vector2i):
	var x =  int(position.x / Globals.GRID_SIZE )
	var y =  int(position.y / Globals.GRID_SIZE )
	var a= map.get_cell_atlas_coords(0, Vector2i(x,y)) == tile
	var b= map.get_cell_atlas_coords(0, Vector2i(x-1,y)) == tile	
	var c= map.get_cell_atlas_coords(0, Vector2i(x,y-1)) == tile	
	var d=	map.get_cell_atlas_coords(0, Vector2i(x-1,y-1)) == tile
	return a || b || c || d
