extends Area2D

const IceShotExplosion := preload("res://scenes/characters/player/IceShotExplosion.tscn")

var speed := 300
var dir := Vector2()
var exploded := false

onready var t := $Tween
onready var particles := $CPUParticles2D


func _ready() -> void:
	t.interpolate_property(particles, "scale_amount", 0, 1, 0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
	t.start()


func _physics_process(delta: float) -> void:
	position += speed * delta * dir


func _on_IceShot_area_entered(area: Area2D) -> void:
	if not area.is_in_group("enemy"):
		return
	if not is_queued_for_deletion():
		area.hit("ice_shot", dir)
	explode()


func _on_DeathTimer_timeout() -> void:
	queue_free()


func explode() -> void:
	if exploded:
		return
	var ice_shot_explosion := IceShotExplosion.instance()
	ice_shot_explosion.position = position
	get_parent().add_child(ice_shot_explosion)
	queue_free()
