extends CPUParticles2D


func _ready() -> void:
	$PenguinExplodeSFX.play()
	emitting = true


func _on_FreeTimer_timeout() -> void:
	queue_free()
