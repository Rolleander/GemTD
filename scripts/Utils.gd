extends Node


func in_range(source : Node2D, target : Node2D, range : float) -> bool:
	return source.global_position.distance_to(target.global_position) <= (range * Globals.TILE_SIZE)/ 2
