extends Node

const Quality = preload("res://scripts/gem_quality.gd").GemQuality
const Type = preload("res://scripts/gem_types.gd").GemType

func in_range(source: Node2D, target: Node2D, range: float, object_r: float = 0) -> bool:
	return source.global_position.distance_to(target.global_position) <= (range * Globals.TILE_SIZE) / 2 + object_r

func selection_tile_is(map: TileMap, position: Vector2, tile: Vector2i):
	var x = int(position.x / Globals.GRID_SIZE)
	var y = int(position.y / Globals.GRID_SIZE)
	var a = map.get_cell_atlas_coords(0, Vector2i(x, y)) == tile
	var b = map.get_cell_atlas_coords(0, Vector2i(x - 1, y)) == tile
	var c = map.get_cell_atlas_coords(0, Vector2i(x, y - 1)) == tile
	var d = map.get_cell_atlas_coords(0, Vector2i(x - 1, y - 1)) == tile
	return a || b || c || d

func get_basic_gem_name(type: Type, quality: Quality):
	var type_info = Globals.get_gem_info(type)
	var quality_info = Globals.get_quality_info(quality)
	var gem_name = ""
	if quality_info.label != null && !quality_info.label.is_empty():
		gem_name += quality_info.label + " "
	gem_name += type_info.label
	return gem_name
