extends AnimatedSprite


func _ready() -> void:
	play("default")


func _on_Splash_animation_finished() -> void:
	queue_free()
