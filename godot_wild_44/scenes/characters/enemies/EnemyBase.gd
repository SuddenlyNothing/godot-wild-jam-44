extends KinematicBody2D

export(int) var health: int = 3 setget set_health
export(int) var max_freeze_health: int = 3

onready var freeze_health: int = max_freeze_health setget set_freeze_health
onready var freeze_timer := $FreezeTimer
onready var slow_timer := $SlowTimer


func set_freeze_health(val: int) -> void:
	if freeze_health > val:
		if val > 0:
			slow_timer.start()
			set_slow(true)
		else:
			freeze_timer.start()
			set_freeze(true)
	freeze_health = val


func set_health(val: int) -> void:
	health = val
	if health <= 0:
		die()


func drown() -> void:
	die()


# Override to add slow effect (slowdown attack speed, move speed, etc.)
func set_slow(val: bool) -> void:
	pass


# Override to add freeze effects.
func set_freeze(val: bool) -> void:
	pass


func die() -> void:
	queue_free()


func _on_Hurtbox_hit(type: String) -> void:
	match type:
		"ice_shot":
			set_freeze_health(freeze_health - 1)
		"pick":
			set_health(health - 1)


func _on_FreezeTimer_timeout() -> void:
	set_freeze(false)
	freeze_health = max_freeze_health


func _on_SlowTimer_timeout() -> void:
	set_slow(false)
