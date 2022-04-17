extends EnemyBase

enum states {
	ENTER,
	ATTACK,
	EXIT,
}

const PenguinBullet := preload("res://scenes/characters/enemies/PenguinBullet.tscn")

var slow_percent := 0.65
var state = states.ENTER
var attack_pattern := []
var attack_positions := []
var anim_ammo := []
var rng := RandomNumberGenerator.new()
var player: Node setget set_player

onready var enter_exit_tween := $EnterExitTween
onready var battle_timer := $BattleTimer
onready var attack_timer := $AttackTimer
onready var attack_delay_timer := $AttackDelayTimer
onready var anim_sprite := $VisualDependents/AnimatedSprite
onready var freeze_texture := $VisualDependents/FreezeTexture
onready var ice_reflection_tween := $IceReflectionTween
onready var attack_sfx := $AttackSFX
onready var cannon_sfx := $CannonSFX
onready var emerge_sfx := $EmergeSFX


func _ready() -> void:
	for i in range(1, 15):
		var new_attack_pos := get_node("AttackPos" + str(i))
		attack_positions.append(new_attack_pos.position)
		anim_ammo.append(new_attack_pos.get_child(0))
		new_attack_pos.get_child(0).play("default")
		yield(get_tree().create_timer(0.1), "timeout")
	enter_exit_tween.interpolate_property(self, "position:y", position.y, position.y + 20,
			2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	enter_exit_tween.start()


func attack() -> void:
	match rng.randi_range(0, 2):
		0: # Random medium 10
			attack_delay_timer.wait_time = 0.4
			for i in 10:
				attack_pattern.append(rng.randi_range(0, attack_positions.size() - 1))
		1: # complete row from left and right side slow 14
			attack_delay_timer.wait_time = 0.4
			for i in 4:
				attack_pattern.append(i)
				attack_pattern.append(13 - i)
			attack_pattern.append(7)
		2: # circle and ends fast 6
			attack_delay_timer.wait_time = 0.4
			for i in range(4, 10):
				attack_pattern.append(i)
			attack_pattern.append(0)
			attack_pattern.append(13)
	attack_sfx.play()
	anim_sprite.play("attack")
	attack_delay_timer.start()


func set_freeze(val: bool) -> void:
	freeze_texture.visible = val
	attack_timer.paused = val
	attack_delay_timer.paused = val
	anim_sprite.speed_scale = 0 if val else 1
	ice_reflection_tween.remove_all()
	ice_reflection_tween.interpolate_property(freeze_texture, "texture_offset:x",
			freeze_texture.texture_offset.x, freeze_texture.texture_offset.x + 128, 1,
			Tween.TRANS_EXPO, Tween.EASE_OUT)
	ice_reflection_tween.start()
	.set_freeze(val)


func set_player(val: Node) -> void:
	player = val


func _on_BattleTimer_timeout() -> void:
	enter_exit_tween.interpolate_property(self, "position:y", position.y, position.y - 700, 5,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	enter_exit_tween.start()
	attack_timer.stop()
	attack_delay_timer.stop()
	state = states.EXIT


func _on_EnterExitTween_tween_all_completed() -> void:
	match state:
		states.ENTER:
			state = states.ATTACK
			battle_timer.start()
			attack_timer.start()
			attack()
		states.EXIT:
			die()


func _on_AttackTimer_timeout() -> void:
	attack()


func _on_AttackDelayTimer_timeout() -> void:
	if attack_pattern.empty():
		return
	cannon_sfx.play()
	var penguin_bullet := PenguinBullet.instance()
	anim_ammo[attack_pattern[0]].frame = 0
	var peng_pos: Vector2 = attack_positions[attack_pattern[0]] + position
	penguin_bullet.position = peng_pos
	penguin_bullet.dir = peng_pos.direction_to(player.position)
	get_parent().add_child(penguin_bullet)
	var splash_particles := SplashParticles.instance()
	splash_particles.position = peng_pos
	get_parent().add_child(splash_particles)
	emerge_sfx.play()
	attack_delay_timer.start()
	attack_pattern.pop_front()


func _on_AnimatedSprite_animation_finished() -> void:
	if anim_sprite.animation == "attack":
		anim_sprite.play("idle")
