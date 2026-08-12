extends NavigationRegion2D


func update_maze(tilemap_rect : Rect2i):
	var gems = get_tree().get_nodes_in_group("building")
	var d = Globals.GRID_SIZE + 5
	var polygon = NavigationPolygon.new()
	polygon.add_outline(PackedVector2Array([
		Vector2(tilemap_rect.position.x * Globals.TILE_SIZE,tilemap_rect.position.y * Globals.TILE_SIZE), 
		Vector2(tilemap_rect.end.x * Globals.TILE_SIZE,tilemap_rect.position.y * Globals.TILE_SIZE), 
		Vector2(tilemap_rect.end.x * Globals.TILE_SIZE,tilemap_rect.end.y * Globals.TILE_SIZE), 
		Vector2(tilemap_rect.position.x * Globals.TILE_SIZE,tilemap_rect.end.y * Globals.TILE_SIZE)]))
	var outline = Array() as Array[  PackedVector2Array]
	for gem in gems:			
		var tile = PackedVector2Array([
		Vector2(gem.position.x -d, gem.position.y - d), 
		Vector2(gem.position.x + d, gem.position.y -d), 
		Vector2(gem.position.x +d, gem.position.y + d),  
		Vector2(gem.position.x - d, gem.position.y +d)])
		outline.append(tile)
	_merge_maze(outline)
	for o in outline:
		polygon.add_outline(o)
	polygon.make_polygons_from_outlines()
	navigation_polygon = polygon

func _merge_maze(outline : Array):
	while true:
		if !_try_merge_maze(outline):
			return
				
func _try_merge_maze(outline : Array) -> bool :
	for o1 in outline:
		for o2 in outline:
			if o1 != o2:	
				var merged = Geometry2D.merge_polygons(o1, o2)
				if merged.size() == 1:
					outline.erase(o1)
					outline.erase(o2)
					outline.append(merged[0])
					return true
	return false			
