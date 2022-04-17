extends TileMap

signal ignore_updated
signal all_tiles_used

export(Vector2) var topleft := Vector2(17, 8)
export(Vector2) var bottomright := Vector2(26, 17)

var rng := RandomNumberGenerator.new()
var ignore := false setget set_ignore

onready var ignore_timer := $IgnoreTimer


func repair_tiles() -> void:
	set_ignore(true)
	for i in range(topleft.x, bottomright.x + 1):
		for j in range(topleft.y, bottomright.y + 1):
			set_cell(i, j, 0)
	update_bitmask_region(topleft, bottomright)
	update_dirty_quadrants()
	ignore_timer.start()


func remove_rand_amount(amount: int) -> void:
	if get_used_cells().size() == 0:
		return
	set_ignore(true)
	if amount >= get_used_cells().size():
		emit_signal("all_tiles_used")
	for i in amount:
		if _remove_rand():
			break
	update_dirty_quadrants()
	call_deferred("set_ignore", false)


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
