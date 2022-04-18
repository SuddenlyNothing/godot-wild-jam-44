extends EnemyMoveStates


func _ready() -> void:
	add_state("retreat")


func _state_logic(delta : float) -> void:
	match state:
		states.move:
			parent.set_target()
		states.retreat:
			parent.apply_soft_collision()
			parent.move_towards_target_pos()
			parent.set_facing()
	._state_logic(delta)


func _enter_state(new_state : String, old_state) -> void:
	match new_state:
		states.idle:
			parent.start_idle_wait_timer()
		states.retreat:
			parent.hitbox_collision.call_deferred("set_disabled", true)
			parent.set_retreat_dir()
			parent.play_anim("move_right")
			parent.start_retreat_timer()
	._enter_state(new_state, old_state)


func _get_transition(delta : float):
	match state:
		states.move:
			if parent.is_player_in_hitbox:
				return states.attack
	return ._get_transition(delta)


func _exit_state(old_state, new_state : String) -> void:
	match old_state:
		states.retreat:
			parent.hitbox_collision.call_deferred("set_disabled", false)
	._exit_state(old_state, new_state)
