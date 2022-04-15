extends Node2D

onready var player := $YSort/Player


func _ready() -> void:
	get_tree().call_group("needs_player", "set_player", player)
	MusicPlayer.play("level")
