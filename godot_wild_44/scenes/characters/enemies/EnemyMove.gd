class_name EnemyMove
extends EnemyBase

export(float) var max_speed := 25
export(float) var friction := 800
export(int) var attack_frame := 5
export(float, 1) var slow_percent := 0.65
export(int) var knockback_force := 200
export(int) var step_frame := 5
export(String) var after_attack_state := "idle"

# If target_dir isn't null and is in idle state, goes to move state
var target_dir
# Position to face towards
var face_pos
var knockback := Vector2()

onready var speed := max_speed
onready var anim_sprite := $VisualDependents/AnimatedSprite
onready var enemy_move_states := $EnemyMoveStates
onready var soft_collision := $VisualDependents/SoftCollision
onready var freeze_texture := $VisualDependents/FreezeTexture
onready var soft_collision_collision := $VisualDependents/SoftCollision/CollisionShape2D
onready var step_sfx := $StepSFX
onready var ice_reflection_tween := $IceReflectionTween


func move_towards_target_pos() -> void:
	if target_dir == null:
		return
	move_and_slide(speed * target_dir)


func apply_knockback(delta: float) -> void:
	move_and_slide(knockback)
	apply_friction(delta)


func apply_friction(delta: float) -> void:
	var friction_amount := friction * delta
	if abs(knockback.length()) <= friction_amount:
		knockback = Vector2()
	else:
		knockback -= friction_amount * knockback.normalized()


func apply_soft_collision() -> void:
	move_and_slide(soft_collision.get_push_velocity())


func set_slow(val: bool) -> void:
	if val:
		speed = max_speed * slow_percent
		anim_sprite.speed_scale = slow_percent
	elif not freeze:
		speed = max_speed
		anim_sprite.speed_scale = 1
	.set_slow(val)


func set_freeze(val: bool) -> void:
	freeze_texture.visible = val
	ice_reflection_tween.interpolate_property(freeze_texture, "texture_offset:x",
			freeze_texture.texture_offset.x, freeze_texture.texture_offset.x + 128, 1,
			Tween.TRANS_EXPO, Tween.EASE_OUT)
	ice_reflection_tween.start()
	
	if val:
		speed = 0
		anim_sprite.speed_scale = 0
	else:
		enemy_move_states.set_queue_state()
		speed = max_speed
		anim_sprite.speed_scale = 1
	.set_freeze(val)


# Override
func attack() -> void:
	pass


func get_hit(hit_dir: Vector2) -> void:
	enemy_move_states.call_deferred("set_state", "knockback")
	knockback = knockback_force * hit_dir
	.get_hit(hit_dir)


func set_facing() -> void:
	if face_pos == null or freeze:
		return
	if (face_pos.x > position.x and visual_dependents.scale.x < 0) or \
			(face_pos.x < position.x and visual_dependents.scale.x > 0):
		visual_dependents.scale.x *= -1


func play_anim(anim: String) -> void:
	if anim_sprite.animation == anim:
		return
	anim_sprite.play(anim)


func _on_AnimatedSprite_frame_changed() -> void:
	if anim_sprite.animation == "attack":
		match anim_sprite.frame:
			attack_frame:
				attack()
	elif anim_sprite.animation == "move_right":
		match anim_sprite.frame:
			step_frame:
				step_sfx.play()


func _on_AnimatedSprite_animation_finished() -> void:
	if anim_sprite.animation == "attack":
		enemy_move_states.call_deferred("set_state", after_attack_state)
