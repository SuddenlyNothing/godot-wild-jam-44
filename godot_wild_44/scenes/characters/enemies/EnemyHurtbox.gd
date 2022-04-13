extends Area2D

signal hit(type)


func hit(type: String) -> void:
	emit_signal("hit", type)
