extends Area2D

var speed := 200
var rot_speed := 15
var dir := Vector2()

onready var sprite := $Sprite


func _process(delta: float) -> void:
	sprite.rotation += rot_speed * delta


func _physics_process(delta: float) -> void:
	position += speed * delta * dir


func _on_Timer_timeout() -> void:
	queue_free()


func _on_PenguinBullet_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	queue_free()
