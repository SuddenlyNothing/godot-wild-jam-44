extends TileMap

signal ignore_updated
signal all_tiles_used

var rng := RandomNumberGenerator.new()
var ignore := false setget set_ignore

onready var ignore_timer := $IgnoreTimer


func remove_rand_amount(amount: int) -> void:
	if amount >= get_used_cells().size():
		emit_signal("all_tiles_used")
	for i in amount:
		if _remove_rand():
			break
	update_dirty_quadrants()
	set_ignore(true)


func get_nearest_valid_pos(pos: Vector2) -> Vector2:
	var nearest_dist
	var nearest_tile
	for cell in get_used_cells():
		var cell_dist = world_to_map(pos).distance_squared_to(cell)
		if nearest_dist == null or cell_dist < nearest_dist:
			nearest_dist = cell_dist
			nearest_tile = cell
	return map_to_world(nearest_tile) + cell_size / 2


func set_ignore(val: bool) -> void:
	ignore = val
	if val:
		ignore_timer.start()
	emit_signal("ignore_updated")


func _remove_rand() -> bool:
	if get_used_cells().size() < 1:
		return true
	var remove_cell = get_used_cells()[rng.randi_range(0, get_used_cells().size() - 1)]
	set_cellv(remove_cell, -1)
	update_bitmask_area(remove_cell)
	return false


func _on_IgnoreTimer_timeout() -> void:
	set_ignore(false)
