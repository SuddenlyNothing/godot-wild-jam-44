extends Node2D

onready var player := $YSort/Player
onready var dialog_player := $CanvasLayer/DialogPlayer


func _ready() -> void:
	get_tree().call_group("needs_player", "set_player", player)
	MusicPlayer.play("level")
	dialog_player.read(["hello world"])
	GDScriptFunctionState
