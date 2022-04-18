tool
class_name EnemySpawner
extends Node2D

signal enemy_eliminated

export(PackedScene) var Enemy setget set_Enemy
export(int) var drop_offset := 100
export(bool) var do_drop := true

var player: Node setget set_player
var enemy: Node

onready var t := $Tween
onready var anim_sprite := $AnimatedSprite


func clear_enemy() -> void:
	if is_instance_valid(enemy):
		t.remove_all()
		anim_sprite.hide()
		enemy.queue_free()


func _enter_tree() -> void:
	_draw_enemy()


func spawn() -> void:
	if do_drop:
		enemy = Enemy.instance()
		anim_sprite.show()
		anim_sprite.position.y = -drop_offset
		anim_sprite.modulate.a = 0
		anim_sprite.frames = enemy.spawn_frames
		anim_sprite.offset = enemy.sprite_offset
		anim_sprite.play("default")
		t.interpolate_property(anim_sprite, "position:y", -drop_offset, 0, 0.5,
				Tween.TRANS_QUAD, Tween.EASE_IN)
		t.interpolate_property(anim_sprite, "modulate:a", 0, 1, 0.5)
		t.start()
	else:
		enemy = Enemy.instance()
		enemy.position = position
		if enemy.is_in_group("needs_player"):
			enemy.set_player(player)
		get_parent().call_deferred("add_child", enemy)
	if player and player.position.x < position.x:
		if "face_pos" in enemy:
			enemy.face_pos = player.position
			if (player.position.x < position.x and anim_sprite.scale.x > 0) or \
				(player.position.x > position.x and anim_sprite.scale.x < 0):
					anim_sprite.scale.x *= -1
	enemy.connect("died", self, "emit_signal", ["enemy_eliminated"])


func set_player(val: Node) -> void:
	if is_instance_valid(enemy):
		if enemy.is_in_group("needs_player"):
			enemy.set_player(player)
	player = val


func set_Enemy(val: PackedScene) -> void:
	Enemy = val
	_draw_enemy()


func _draw_enemy() -> void:
	$AnimatedSprite.visible = Engine.editor_hint
	if Engine.editor_hint:
		if Enemy:
			var enemy = Enemy.instance()
			$AnimatedSprite.frames = enemy.spawn_frames
			$AnimatedSprite.offset = enemy.sprite_offset


func _on_Tween_tween_all_completed() -> void:
	if not is_instance_valid(enemy):
		return
	enemy.position = position
	if enemy.is_in_group("needs_player"):
		enemy.set_player(player)
	anim_sprite.hide()
	get_parent().add_child(enemy)
	get_tree().call_group("dynamic_camera", "shake")
