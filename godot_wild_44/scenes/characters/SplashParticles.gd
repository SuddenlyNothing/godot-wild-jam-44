extends CPUParticles2D


func _ready() -> void:
	emitting = true
	$CenterSplashParticles.emitting = true


func _on_FreeTimer_timeout() -> void:
	queue_free()
