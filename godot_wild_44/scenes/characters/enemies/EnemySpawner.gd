extends Node2D

export(PackedScene) var Enemy
export(int) var drop_offset := 100

var player: Node setget set_player
var enemy: Node

onready var t := $Tween
onready var anim_sprite := $AnimatedSprite


func _ready() -> void:
	enemy = Enemy.instance()
	anim_sprite.frames = enemy.spawn_frames
	anim_sprite.offset = enemy.sprite_offset
	anim_sprite.play("default")
	t.interpolate_property(anim_sprite, "position:y", -drop_offset, 0, 1,
			Tween.TRANS_EXPO, Tween.EASE_IN)
	t.interpolate_property(anim_sprite, "modulate:a", 0, 1, 1)
	t.start()


func set_player(val: Node) -> void:
	player = val


func _on_Tween_tween_all_completed() -> void:
	enemy.position = position
	if enemy.is_in_group("needs_player"):
		enemy.set_player(player)
	get_parent().add_child(enemy)
	queue_free()
