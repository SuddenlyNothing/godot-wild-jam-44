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
			parent.set_retreat_dir()
			parent.play_anim("move_right")
			parent.start_retreat_timer()
	._enter_state(new_state, old_state)
