extends StateMachine


func _ready() -> void:
	add_state("idle")
	add_state("walk")
	add_state("death")
	call_deferred("set_state", "idle")


# Contains state logic.
func _state_logic(delta : float) -> void:
	match state:
		states.idle:
			parent.set_anim("idle")
			parent.apply_soft_collision()
		states.walk:
			parent.move()
			parent.set_anim("walk")
			parent.apply_soft_collision()


# Return value will be used to change state.
func _get_transition(delta : float):
	match state:
		states.idle:
			if parent.input != Vector2():
				return states.walk
		states.walk:
			if parent.input == Vector2():
				return states.idle
	return null


# Called on entering state.
# new_state is the state being entered.
# old_state is the state being exited.
func _enter_state(new_state : String, old_state) -> void:
	match new_state:
		states.idle:
			pass
		states.walk:
			pass
		states.death:
			parent.play_anim("idle_right")
			_set_disabled(true)


# Called on exiting state.
# old_state is the state being exited.
# new_state is the state being entered.
func _exit_state(old_state, new_state : String) -> void:
	match old_state:
		states.idle:
			pass
		states.walk:
			pass
		states.death:
			_set_disabled(false)


func _set_disabled(val: bool) -> void:
	set_physics_process(not val)
	parent.disabled = val
