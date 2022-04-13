extends TileMap


func get_nearest_valid_pos(pos: Vector2) -> Vector2:
	var nearest_dist
	var nearest_tile
	for cell in get_used_cells():
		var cell_dist = world_to_map(pos).distance_squared_to(cell)
		if nearest_dist == null or cell_dist < nearest_dist:
			nearest_dist = cell_dist
			nearest_tile = cell
	return map_to_world(nearest_tile) + cell_size / 2
