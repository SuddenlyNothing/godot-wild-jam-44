extends Node

signal wave_finished

var child_ind := 1
var enemies_eliminated := 0

onready var total_enemies := get_child_count() - 1
onready var spawn_delay := $SpawnDelay


func _ready() -> void:
	for i in range(1, get_child_count()):
		get_child(i).connect("enemy_eliminated", self, "_on_enemy_eliminated")
	spawn()


func spawn() -> void:
	enemies_eliminated = 0
	child_ind = 1
	spawn_delay.start()


func _on_SpawnDelay_timeout() -> void:
	get_child(child_ind).spawn()
	child_ind += 1
	if child_ind < get_child_count():
		spawn_delay.start()


func _on_enemy_eliminated() -> void:
	enemies_eliminated += 1
	if enemies_eliminated == total_enemies:
		print("wave finished")
		emit_signal("wave_finished")
