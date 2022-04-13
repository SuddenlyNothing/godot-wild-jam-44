extends KinematicBody2D

signal started_pull

const IceShot := preload("res://scenes/characters/player/IceShot.tscn")
const Splash := preload("res://scenes/environment/Splash.tscn")

const MAX_SPEED := 100
const REACH := 24

var prev_input := Vector2()
var input := Vector2()
var ice_tiles : Node
var enemies_in_hitbox := {}

onready var player_states := $PlayerStates
onready var anim_sprite := $AnimatedSprite
onready var melee_timer := $MeleeTimer
onready var shoot_timer := $ShootTimer
onready var shoot_pos := $ShootPos
onready var hitbox := $Hitbox
onready var respawn_timer := $RespawnTimer
onready var t := $Tween


func _ready() -> void:
	get_tree().call_group("needs_player", "set_player", self)


func _process(_delta: float) -> void:
	var new_input := Input.get_vector("left", "right", "up", "down")
	if input != Vector2():
		prev_input = input
	input = new_input
	
	_set_facing()
	_attack()


func move() -> void:
	move_and_slide(input * MAX_SPEED)


func drown() -> void:
	var splash := Splash.instance()
	splash.position = position
	get_parent().add_child(splash)
	player_states.call_deferred("set_state", "death")
	respawn_timer.start()
	t.interpolate_property(self, "position", position,
			get_tree().get_nodes_in_group("ice_tiles")[0].get_nearest_valid_pos(position),
			respawn_timer.wait_time, Tween.TRANS_EXPO, Tween.EASE_IN)
	t.start()


func set_anim(anim_prefix: String) -> void:
	var look_ang : float = shoot_pos.get_local_mouse_position().angle()
	var anim_dir := ""
	match anim_prefix:
		"walk":
			if _is_between(look_ang, -PI / 4, PI / 4) or \
					(look_ang > PI * 3 / 4 or look_ang < -PI * 3 / 4):
				anim_dir = "right"
			elif _is_between(look_ang, -PI * 3 / 4, -PI / 4):
				anim_dir = "up"
			else:
				anim_dir = "down"
		"idle":
			if _is_between(look_ang, -PI / 4, PI / 4) or \
					(look_ang > PI * 3 / 4 or look_ang < -PI * 3 / 4):
				anim_dir = "right"
			elif _is_between(look_ang, -PI * 3 / 4, -PI / 4):
				anim_dir = "up"
			else:
				anim_dir = "down"
	_play_anim(anim_prefix + "_" + anim_dir)


func _attack() -> void:
	if not (melee_timer.is_stopped() and shoot_timer.is_stopped()):
		return
	if Input.is_action_pressed("melee"):
		_melee_attack()
		melee_timer.start()
	elif Input.is_action_pressed("shoot"):
		var ice_shot := IceShot.instance()
		ice_shot.position = shoot_pos.global_position
		ice_shot.dir = shoot_pos.get_local_mouse_position().normalized()
		get_parent().add_child(ice_shot)
		shoot_timer.start()


func _melee_attack() -> void:
	for enemy in enemies_in_hitbox:
		enemy.hit("pick")


func _play_anim(anim: String) -> void:
	if anim_sprite.animation == anim:
		return
	anim_sprite.play(anim)


func _set_facing() -> void:
	var look_dir : Vector2 = shoot_pos.get_local_mouse_position()
	if (look_dir.x > 0 and anim_sprite.scale.x < 0) or \
			(look_dir.x < 0 and anim_sprite.scale.x > 0):
		anim_sprite.scale.x *= -1
	hitbox.rotation = look_dir.angle()


func _is_between(check_val: float, min_v: float, max_v: float) -> bool:
	return (check_val >= min_v and check_val <= max_v)


func _on_Hitbox_area_entered(area: Area2D) -> void:
	if not area.is_in_group("enemy"):
		return
	enemies_in_hitbox[area] = 0


func _on_Hitbox_area_exited(area: Area2D) -> void:
	if not area.is_in_group("enemy"):
		return
	enemies_in_hitbox.erase(area)


func _on_RespawnTimer_timeout() -> void:
	player_states.call_deferred("set_state", "idle")
