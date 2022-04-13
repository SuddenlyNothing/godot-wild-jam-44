extends CPUParticles2D

onready var free_timer := $FreeTimer


func _ready() -> void:
	emitting = true
	free_timer.start(lifetime)


func _on_FreeTimer_timeout() -> void:
	queue_free()
