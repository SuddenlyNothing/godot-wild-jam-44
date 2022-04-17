extends YSort

signal wave_finished

var child_ind := 1
var enemies_eliminated := 0

onready var total_enemies := get_child_count() - 1
onready var spawn_delay := $SpawnDelay


func _ready() -> void:
	for i in range(1, get_child_count()):
		get_child(i).connect("enemy_eliminated", self, "_on_enemy_eliminated")


func clear_enemies() -> void:
	for child in get_children():
		if child.is_in_group("enemy_spawner"):
			child.clear_enemy()
	spawn_delay.stop()


func spawn() -> void:
	enemies_eliminated = 0
	child_ind = 1
	spawn_delay.start()


func _on_SpawnDelay_timeout() -> void:
	var child = get_child(child_ind)
	if not child is EnemySpawner:
		return
	child.spawn()
	child_ind += 1
	if child_ind < get_child_count():
		spawn_delay.start()


func _on_enemy_eliminated() -> void:
	enemies_eliminated += 1
	if enemies_eliminated == total_enemies:
		emit_signal("wave_finished")
