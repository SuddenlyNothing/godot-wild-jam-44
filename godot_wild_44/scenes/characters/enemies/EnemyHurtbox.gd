extends Area2D

signal hit(type, hit_dir)


func hit(type: String, hit_dir: Vector2) -> void:
	emit_signal("hit", type, hit_dir)
