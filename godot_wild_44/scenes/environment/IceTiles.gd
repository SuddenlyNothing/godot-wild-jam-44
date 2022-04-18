extends TileMap

signal all_tiles_used

const IceBreakParticles := preload("res://scenes/environment/IceBreakParticles.tscn")
const IceRepairParticles := preload("res://scenes/environment/IceRepairParticles.tscn")

export(Vector2) var topleft := Vector2(17, 8)
export(Vector2) var bottomright := Vector2(26, 17)

var rng := RandomNumberGenerator.new()

onready var ice_break_sfx := $IceBreakSFX
onready var freeze_sfx := $FreezeSFX


func _physics_process(_delta: float) -> void:
	check_drownable()


func check_drownable() -> void:
	var drownables = get_tree().get_nodes_in_group("drownable")
	for i in drownables:
		if not is_rect_safe(i.position, i.get_rect()):
			i.drown()


func is_rect_safe(pos: Vector2, rect: Vector2) -> bool:
	if get_cellv(world_to_map(pos + rect)) != -1 or\
			get_cellv(world_to_map(pos - rect)) != -1 or\
			get_cellv(world_to_map(pos + Vector2(rect.x, -rect.y))) != -1 or\
			get_cellv(world_to_map(pos + Vector2(-rect.x, rect.y))) != -1 or\
			get_cellv(world_to_map(pos)) != -1:
		return true
	return false


func repair_tiles() -> void:
	for i in range(topleft.x, bottomright.x + 1):
		for j in range(topleft.y, bottomright.y + 1):
			if get_cell(i, j) == -1:
				set_cell(i, j, 0)
				var ice_repair_particles := IceRepairParticles.instance()
				ice_repair_particles.z_index = -1
				ice_repair_particles.position = map_to_world(Vector2(i, j)) +\
						cell_size / 2
				add_child(ice_repair_particles)
	update_bitmask_region(topleft, bottomright)
	update_dirty_quadrants()
	freeze_sfx.play()


func remove_rand_amount(amount: int) -> void:
	if get_used_cells().size() == 0:
		return
	if amount >= get_used_cells().size():
		emit_signal("all_tiles_used")
	for i in amount:
		if _remove_rand():
			break
	update_dirty_quadrants()
	ice_break_sfx.play()


func get_nearest_valid_pos(pos: Vector2) -> Vector2:
	var nearest_dist
	var nearest_tile
	for cell in get_used_cells():
		var cell_dist = world_to_map(pos).distance_squared_to(cell)
		if nearest_dist == null or cell_dist < nearest_dist:
			nearest_dist = cell_dist
			nearest_tile = cell
	return map_to_world(nearest_tile) + cell_size / 2


func _remove_rand() -> bool:
	if get_used_cells().size() < 1:
		return true
	var remove_cell = get_used_cells()[rng.randi_range(0, get_used_cells().size() - 1)]
	set_cellv(remove_cell, -1)
	update_bitmask_area(remove_cell)
	var ice_break_particles := IceBreakParticles.instance()
	ice_break_particles.z_index = -1
	ice_break_particles.position = map_to_world(remove_cell) + cell_size / 2
	add_child(ice_break_particles)
	return false
