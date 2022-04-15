class_name EnemyMoveStates
extends StateMachine

var queue_state


func _ready() -> void:
	add_state("idle")
	add_state("move")
	add_state("knockback")
	add_state("attack")
	call_deferred("set_state", "idle")


# Contains state logic.
func _state_logic(delta : float) -> void:
	match state:
		states.idle:
			parent.apply_soft_collision()
		states.move:
			parent.apply_soft_collision()
			parent.move_towards_target_pos()
			parent.set_facing()
		states.knockback:
			parent.apply_knockback(delta)
		states.attack:
			parent.apply_soft_collision()

# Return value will be used to change state.
func _get_transition(delta : float):
	match state:
		states.idle:
			if parent.target_dir != null:
				return states.move
		states.move:
			pass
		states.knockback:
			if parent.knockback == Vector2():
				return states.idle
		states.attack:
			pass
	return null

# Called on entering state.
# new_state is the state being entered.
# old_state is the state being exited.
func _enter_state(new_state : String, old_state) -> void:
	match new_state:
		states.idle:
			parent.play_anim("idle")
		states.move:
			parent.play_anim("move_right")
		states.knockback:
			parent.play_anim("move_right")
		states.attack:
			parent.play_anim("attack")

# Called on exiting state.
# old_state is the state being exited.
# new_state is the state being entered.
func _exit_state(old_state, new_state : String) -> void:
	match old_state:
		states.idle:
			pass
		states.move:
			pass
		states.knockback:
			pass
		states.attack:
			pass


func set_state(new_state: String) -> void:
	if parent.freeze:
		queue_state = new_state
	else:
		.set_state(new_state)


func set_queue_state() -> void:
	if queue_state != null:
		call_deferred("set_state", queue_state)
		queue_state = null
