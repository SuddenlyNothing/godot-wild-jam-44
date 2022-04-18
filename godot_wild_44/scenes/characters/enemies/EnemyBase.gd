class_name EnemyBase
extends KinematicBody2D

signal died

const DeathParticles := preload("res://scenes/characters/enemies/DeathParticles.tscn")
const IceDeathParticles := preload("res://scenes/characters/enemies/" +\
		"IceDeathParticles.tscn")
const SplashParticles := preload("res://scenes/characters/SplashParticles.tscn")
const DamageCounter := preload("res://ui/gameplay/DamageCounter.tscn")

export(SpriteFrames) var spawn_frames
export(Vector2) var sprite_offset
export(int) var health: int = 3 setget set_health
export(int) var max_freeze_health: int = 3
export(Color) var slow_color := Color("dfeded")
export(Color) var hurt_color := Color("bf2651")

var freeze := false setget set_freeze
var died := false

onready var freeze_health: int = max_freeze_health setget set_freeze_health
onready var freeze_timer := $FreezeTimer
onready var slow_timer := $SlowTimer
onready var visual_dependents := $VisualDependents
onready var t := $Tween
onready var frozen_break_sfx := $FrozenBreakSFX
onready var freeze_sfx := $FreezeSFX
onready var particle_position := $VisualDependents/ParticlePosition
onready var hurt_sfx := $HurtSFX
onready var death_sfx := $DeathSFX
onready var ice_hit_sfx := $IceHitSFX


func set_freeze_health(val: int) -> void:
	if freeze_health > val:
		if val > 0:
			slow_timer.start()
			set_slow(true)
		else:
			freeze_timer.start()
			set_freeze(true)
	freeze_health = val


func set_health(val: int, hit_dir: Vector2 = Vector2()) -> void:
	if freeze:
		val -= 2
	if not (is_inside_tree() or val < health):
		health = val
		return
	get_hit(hit_dir)
	if val <= 0:
		if freeze:
			remove_child(frozen_break_sfx)
			get_parent().add_child(frozen_break_sfx)
			frozen_break_sfx.position = position
			frozen_break_sfx.connect("finished", frozen_break_sfx, "queue_free")
			frozen_break_sfx.play()
			var ice_death_particles := IceDeathParticles.instance()
			ice_death_particles.position = particle_position.global_position
			get_parent().add_child(ice_death_particles)
		else:
			var death_particles := DeathParticles.instance()
			death_particles.position = particle_position.global_position
			get_parent().add_child(death_particles)
		death_sfx.play()
		death_sfx.position = position
		remove_child(death_sfx)
		get_parent().add_child(death_sfx)
		death_sfx.connect("finished", death_sfx, "queue_free")
		die()
	else:
		if freeze:
			ice_hit_sfx.play()
		hurt_sfx.play()
	var damage_counter := DamageCounter.instance()
	damage_counter.position = particle_position.global_position
	damage_counter.text = str(health - val)
	get_parent().add_child(damage_counter)
	health = val


func get_hit(hit_dir: Vector2) -> void:
	_flash_hurt()


func drown() -> void:
	if not is_queued_for_deletion():
		var splash_particles := SplashParticles.instance()
		splash_particles.position = position
		get_parent().add_child(splash_particles)
	die()


# Override to add slow effect (slowdown attack speed, move speed, etc.)
func set_slow(val: bool) -> void:
	if val:
		_flash_slow()


# Override to add freeze effects.
func set_freeze(val: bool) -> void:
	if val:
		freeze_sfx.play()
		_flash_slow()
	else:
		frozen_break_sfx.play()
	freeze = val


func die() -> void:
	if died:
		return
	died = true
	if frozen_break_sfx.playing and is_a_parent_of(frozen_break_sfx):
		remove_child(frozen_break_sfx)
		get_parent().add_child(frozen_break_sfx)
		frozen_break_sfx.position = position
		frozen_break_sfx.connect("finished", frozen_break_sfx, "queue_free")
	emit_signal("died")
	get_tree().call_group("dynamic_camera", "shake")
	queue_free()


func _flash_hurt() -> void:
	visual_dependents.get_material().set_shader_param("hit_color", hurt_color)
	t.remove_all()
	t.interpolate_property(visual_dependents.get_material(), "shader_param/hit_strength",
		1, 0, 0.3)
	t.start()


func _flash_slow() -> void:
	if visual_dependents.get_material().get_shader_param("hit_color") == hurt_color and \
			t.is_active():
		return
	visual_dependents.get_material().set_shader_param("hit_color", slow_color)
	t.remove_all()
	t.interpolate_property(visual_dependents.get_material(), "shader_param/hit_strength",
			1, 0, slow_timer.wait_time, Tween.TRANS_SINE, Tween.EASE_OUT)
	t.start()


func _on_Hurtbox_hit(type: String, hit_dir: Vector2) -> void:
	match type:
		"ice_shot":
			set_freeze_health(freeze_health - 1)
		"pick":
			set_health(health - 1, hit_dir)


func _on_FreezeTimer_timeout() -> void:
	set_freeze(false)
	freeze_health = max_freeze_health


func _on_SlowTimer_timeout() -> void:
	set_slow(false)
	freeze_health += 1
