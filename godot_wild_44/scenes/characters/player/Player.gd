extends KinematicBody2D

signal started_pull

const IceShot := preload("res://scenes/characters/player/IceShot.tscn")
const Splash := preload("res://scenes/environment/Splash.tscn")

const MAX_SPEED := 100
const REACH := 12
const PICK_OFFSET := Vector2(0, -7)
const KNOCKBACK_FORCE := 200
const FRICTION := 800

var prev_input := Vector2()
var input := Vector2()
var ice_tiles : Node
var enemies_in_hitbox := {}
var disabled := false setget set_disabled
var knockback := Vector2()
var look_dir := Vector2()
var is_pick_left := true
var is_picking := false
var is_shooting := false

onready var player_states := $PlayerStates
onready var anim_sprite := $YSort/AnimatedSprite
onready var melee_timer := $MeleeTimer
onready var shoot_timer := $ShootTimer
onready var shoot_pos := $YSort/SnowMachine/ShootPos
onready var hitbox := $Hitbox
onready var respawn_timer := $RespawnTimer
onready var t := $Tween
onready var hit_flash_tween := $HitFlashTween
onready var soft_collision := $SoftCollision
onready var step_sfx := $StepSFX
onready var pick_swing_sfx := $PickSwingSFX
onready var ice_shot_sfx := $IceShotSFX
onready var splash_sfx := $SplashSFX
onready var emerge_sfx := $EmergeSFX
onready var pick := $YSort/Pick
onready var swing_tween := $SwingTween
onready var snow_machine := $YSort/SnowMachine
onready var snow_machine_tween := $SnowMachineTween

onready var body_collision := $CollisionShape2D
onready var hitbox_collision := $Hitbox/CollisionShape2D
onready var soft_collision_collision := $SoftCollision/CollisionShape2D


func _ready() -> void:
	get_tree().call_group("needs_player", "set_player", self)
	look_dir = get_local_mouse_position().normalized()
	_set_pick_facing(1)


func _process(delta: float) -> void:
	var new_input := Input.get_vector("left", "right", "up", "down")
	if input != Vector2():
		prev_input = input
	input = new_input
	
	look_dir = (get_local_mouse_position() - PICK_OFFSET).normalized()
	
	_set_facing()
	_set_pick_facing(delta)
	_set_snow_machine_facing(delta)
	_attack()


func _unhandled_input(event: InputEvent) -> void:
	_set_attack_inputs(event)


func _physics_process(delta: float) -> void:
	_apply_knockback(delta)


func move() -> void:
	move_and_slide(input * MAX_SPEED)


func drown() -> void:
	if not respawn_timer.is_inside_tree():
		return
	get_tree().call_group_flags(2, "ice_tiles", "remove_rand_amount", 300)
	splash_sfx.play()
	var splash := Splash.instance()
	splash.position = position
	get_parent().add_child(splash)
	player_states.call_deferred("set_state", "death")
	var ice_tiles := get_tree().get_nodes_in_group("ice_tiles")
	if not ice_tiles.empty() and ice_tiles[0].get_used_cells().size() > 0:
		respawn_timer.start()
		t.interpolate_property(self, "position", position,
				get_tree().get_nodes_in_group("ice_tiles")[0].get_nearest_valid_pos(position),
				respawn_timer.wait_time, Tween.TRANS_EXPO, Tween.EASE_IN)
		t.start()


func hit(hit_dir: Vector2, hit_strength: int) -> void:
	hit_flash_tween.interpolate_property(anim_sprite.get_material(), "shader_param/hit_strength",
			1, 0, 0.3)
	hit_flash_tween.start()
	knockback = KNOCKBACK_FORCE * hit_strength * hit_dir
	get_tree().call_group("ice_tiles", "remove_rand_amount", 3)


func set_anim(anim_prefix: String) -> void:
	var look_ang : float = look_dir.angle()
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
	play_anim(anim_prefix + "_" + anim_dir)


func respawn() -> void:
	player_states.call_deferred("set_state", "idle")


func apply_soft_collision() -> void:
	move_and_slide(soft_collision.get_push_velocity())


func set_disabled(val: bool) -> void:
	disabled = val
	body_collision.call_deferred("set_disabled", val)
	hitbox_collision.call_deferred("set_disabled", val)
	soft_collision_collision.call_deferred("set_disabled", val)
	set_process(not val)
	set_physics_process(not val)
	set_process_unhandled_input(not val)
	if not val:
		is_picking = Input.is_action_pressed("melee")
		is_shooting = Input.is_action_pressed("shoot")
	visible = not val


func _apply_knockback(delta: float) -> void:
	move_and_slide(knockback)
	_apply_friction(delta)


func _apply_friction(delta: float) -> void:
	var friction_amount := FRICTION * delta
	if knockback.length() <= friction_amount:
		knockback = Vector2()
	else:
		knockback -= FRICTION * delta * knockback.normalized()


func _set_attack_inputs(event: InputEvent):
	if event.is_action("melee"):
		is_picking = event.is_action_pressed("melee")
	if event.is_action("shoot"):
		is_shooting = event.is_action_pressed("shoot")


func _attack() -> void:
	if not (melee_timer.is_stopped() and shoot_timer.is_stopped()):
		return
	if is_picking:
		_melee_attack()
	elif is_shooting:
		_ice_shot()


func _melee_attack() -> void:
	pick.show()
	snow_machine.hide()
	swing_tween.remove_all()
	if is_pick_left:
		swing_tween.interpolate_property(pick, "rotation", pick.rotation, pick.rotation - PI, 0.3,
				Tween.TRANS_QUART, Tween.EASE_OUT)
	else:
		swing_tween.interpolate_property(pick, "rotation", pick.rotation, pick.rotation + PI, 0.3,
				Tween.TRANS_QUART, Tween.EASE_OUT)
	swing_tween.start()
	is_pick_left = not is_pick_left
	pick_swing_sfx.play()
	melee_timer.start()
	for enemy in enemies_in_hitbox:
		enemy.hit("pick", look_dir)


func _ice_shot() -> void:
	snow_machine.show()
	pick.hide()
	var ice_shot := IceShot.instance()
	ice_shot.position = shoot_pos.global_position
	ice_shot.dir = (get_global_mouse_position() - shoot_pos.global_position).normalized()
	get_parent().add_child(ice_shot)
	shoot_timer.start()
	ice_shot_sfx.play()
	snow_machine_tween.remove_all()
	snow_machine_tween.interpolate_property(snow_machine, "offset:y", 5, -3, 0.1)
	snow_machine_tween.start()


func play_anim(anim: String) -> void:
	if anim_sprite.animation == anim:
		return
	anim_sprite.play(anim)


func _set_facing() -> void:
	if (look_dir.x > 0 and anim_sprite.scale.x < 0) or \
			(look_dir.x < 0 and anim_sprite.scale.x > 0):
		anim_sprite.scale.x *= -1


func _set_pick_facing(delta: float) -> void:
	if swing_tween.is_active():
		return
	pick.position = lerp(pick.position, look_dir * REACH + PICK_OFFSET, min(15 * delta, 1))
	var pick_rot := look_dir.angle() + PI / 2
	if is_pick_left:
		pick_rot += PI / 2
	else:
		pick_rot -= PI / 2
	pick.rotation = lerp_angle(pick.rotation, pick_rot, min(15 * delta, 1))
	hitbox.position = look_dir * REACH * 2 + PICK_OFFSET
	hitbox.rotation = look_dir.angle()


func _set_snow_machine_facing(delta: float) -> void:
	if (look_dir.x > 0 and snow_machine.scale.x > 0) or \
			(look_dir.x < 0 and snow_machine.scale.x < 0):
		snow_machine.scale.x *= -1
	snow_machine.position = lerp(snow_machine.position, look_dir * REACH + PICK_OFFSET,
			min(15 * delta, 1))
	snow_machine.rotation = lerp_angle(snow_machine.rotation, look_dir.angle() + PI / 2,
			min(15 * delta, 1))


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
	emerge_sfx.play()
	player_states.call_deferred("set_state", "idle")


func _on_AnimatedSprite_frame_changed() -> void:
	match anim_sprite.animation:
		"walk_right", "walk_down", "walk_up":
			match anim_sprite.frame:
				3, 7:
					step_sfx.play()
