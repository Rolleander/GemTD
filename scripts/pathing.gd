extends Node

class_name Pathing 

var astar = AStarGrid2D.new()

func create_maze(rect : Rect2i):
	astar.region = Rect2i(rect.position.x, rect.position.y, rect.position.x  + rect.size.x * 2, rect.position.y + rect.size.y * 2 )
	astar.cell_size = Vector2i(Globals.GRID_SIZE, Globals.GRID_SIZE)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.update()	
			
func find_path(from : Vector2 , target : Vector2):
	return astar.get_point_path(from / Globals.GRID_SIZE, target / Globals.GRID_SIZE)

func set_block(node : Vector2, blocked = true ):
	var x =  int(node.x / Globals.GRID_SIZE)
	var y =  int(node.y / Globals.GRID_SIZE)
	astar.set_point_solid(Vector2i(x,y), blocked)
	astar.set_point_solid(Vector2i(x-1,y), blocked)
	astar.set_point_solid(Vector2i(x,y-1), blocked)
	astar.set_point_solid(Vector2i(x-1,y-1), blocked)


