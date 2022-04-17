extends Area2D

const PenguinExplosionParticles := preload(
		"res://scenes/characters/enemies/PenguinExplosionParticles.tscn")

var speed := 200
var rot_speed := 15
var dir := Vector2()

onready var sprite := $Sprite


func _process(delta: float) -> void:
	sprite.rotation += rot_speed * delta


func _physics_process(delta: float) -> void:
	position += speed * delta * dir


func hit(_type: String, _d: Vector2) -> void:
	var penguin_explosion_particles := PenguinExplosionParticles.instance()
	penguin_explosion_particles.position = position
	get_parent().add_child(penguin_explosion_particles)
	queue_free()


func _on_Timer_timeout() -> void:
	queue_free()


func _on_PenguinBullet_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	var penguin_explosion_particles := PenguinExplosionParticles.instance()
	penguin_explosion_particles.position = position
	get_parent().add_child(penguin_explosion_particles)
	body.hit(dir, 1)
	queue_free()
