extends CPUParticles2D

onready var free_timer := $FreeTimer
onready var hit_sfx := $HitSFX


func _ready() -> void:
	emitting = true
	hit_sfx.play()
	free_timer.start(lifetime)


func _on_FreeTimer_timeout() -> void:
	queue_free()
