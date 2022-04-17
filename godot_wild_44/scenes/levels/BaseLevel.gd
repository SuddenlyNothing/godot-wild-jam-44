class_name BaseLevel
extends Node2D

export(Array, Array, String, MULTILINE) var events := []
export(String, FILE, "*.tscn") var next_scene

var wave := 0
var events_state: GDScriptFunctionState

onready var player := $YSort/Player
onready var start_pos: Vector2 = player.position
onready var dialog_player := $CL/DialogPlayer
onready var lose_screen := $CL/LoseScreen
onready var ice_tiles := $DrownHandler/IceTiles
onready var wave_parent := $YSort/WaveParent


func events() -> void:
	for i in events:
		if i.empty():
			wave_parent.get_child(wave).spawn()
		else:
			dialog_player.read(i)
		yield()
	SceneHandler.goto_scene(next_scene)


func _ready() -> void:
	for child in wave_parent.get_children():
		child.connect("wave_finished", self, "_on_WaveHandler_wave_finished")
	MusicPlayer.play("level")
	get_tree().call_group("needs_player", "set_player", player)
	events_state = events()


# Fills ice tiles again and retries the current wave
func _on_LoseScreen_retry_wave_pressed() -> void:
	ice_tiles.repair_tiles()
	player.position = start_pos
	wave_parent.get_child(wave).spawn()
	player.respawn()


# Restarts the level
# Fill ice tiles
# Reset events and wave count
# Move respawn and move player back to origin
func _on_LoseScreen_restart_pressed() -> void:
	ice_tiles.repair_tiles()
	wave = 0
	player.position = start_pos
	player.respawn()
	events_state = events()


# Shows lose menu
func _on_IceTiles_all_tiles_used() -> void:
	wave_parent.get_child(wave).clear_enemies()
	lose_screen.enter()


# Starts next event
func _on_DialogPlayer_dialog_finished() -> void:
	events_state = events_state.resume()


# Starts next event
func _on_WaveHandler_wave_finished() -> void:
	events_state = events_state.resume()
