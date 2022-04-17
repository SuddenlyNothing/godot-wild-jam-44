class_name BaseLevel
extends Node2D

export(Array, Array, String, MULTILINE) var events := []
export(Array, Color, RGB) var text_color
export(Array, float) var time_delay
export(String, FILE, "*.tscn") var next_scene

var wave := 0
var events_state: GDScriptFunctionState
var previous_event

onready var event_delay_timer := $EventDelayTimer
onready var player := $YSort/Player
onready var start_pos: Vector2 = player.position
onready var dialog_player := $CL/DialogPlayer
onready var lose_screen := $CL/LoseScreen
onready var ice_tiles := $IceTiles
onready var wave_parent := $YSort/WaveParent


func events() -> void:
	for i in events.size():
		if time_delay.size() > i:
			event_delay_timer.start(time_delay[i])
			yield()
		if previous_event != null:
			exit_event(previous_event)
		enter_event(i)
		previous_event = i
		var event = events[i]
		if event.empty():
			wave_parent.get_child(wave).spawn()
		else:
			if text_color.size() > i:
				dialog_player.read(event, text_color[i])
			else:
				dialog_player.read(event)
		yield()
	SceneHandler.goto_scene(next_scene)


# Override for customizable options
func enter_event(n: int) -> void:
	pass


func exit_event(n: int) -> void:
	pass


func _ready() -> void:
	for child in wave_parent.get_children():
		child.connect("wave_finished", self, "_on_WaveHandler_wave_finished")
	MusicPlayer.play("level")
	get_tree().call_group("needs_player", "set_player", player)
	events_state = events()


# Fills ice tiles again and retries the current wave
func _on_LoseScreen_retry_wave_pressed() -> void:
	dialog_player.stop()
	ice_tiles.repair_tiles()
	player.position = start_pos
	player.respawn()
	wave_parent.get_child(wave).spawn()


# Restarts the level
# Fill ice tiles
# Reset events and wave count
# Move respawn and move player back to origin
func _on_LoseScreen_restart_pressed() -> void:
	dialog_player.stop()
	ice_tiles.repair_tiles()
	wave = 0
	player.position = start_pos
	player.respawn()
	events_state = events()


# Shows lose menu
func _on_IceTiles_all_tiles_used() -> void:
	if wave >= wave_parent.get_child_count():
		return
	dialog_player.stop()
	wave_parent.get_child(wave).clear_enemies()
	get_tree().call_group("enemy", "queue_free")
	lose_screen.enter()


# Starts next event
func _on_DialogPlayer_dialog_finished() -> void:
	events_state = events_state.resume()


# Starts next event
func _on_WaveHandler_wave_finished() -> void:
	if ice_tiles.get_used_cells().empty():
		return
	wave += 1
	ice_tiles.repair_tiles()
	events_state = events_state.resume()


func _on_EventDelayTimer_timeout() -> void:
	events_state = events_state.resume()
