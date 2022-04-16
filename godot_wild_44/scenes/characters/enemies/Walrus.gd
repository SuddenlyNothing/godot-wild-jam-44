extends EnemyMove

export(int) var hit_scale := 1

onready var idle_wait_timer := $IdleWaitTimer
onready var hitbox := $VisualDependents/Hitbox
onready var attack_pos := $VisualDependents/AttackPos
onready var retreat_timer := $RetreatTimer
onready var hitbox_collision := $VisualDependents/Hitbox/CollisionShape2D


func set_target() -> void:
	target_dir = attack_pos.global_position.direction_to(player.position)
	face_pos = player.position


func set_retreat_dir() -> void:
	target_dir = player.position.direction_to(attack_pos.global_position).rotated(
			(randf() - 1) * PI / 2)
	face_pos = player.position


func attack() -> void:
	for body in hitbox.get_overlapping_bodies():
		if body == player:
			body.hit(position.direction_to(body.position), hit_scale)


func start_idle_wait_timer() -> void:
	if randf() > 0.5:
		idle_wait_timer.start(randf() * 2)
	else:
		idle_wait_timer.start(randf() * 3 + 3)


func start_retreat_timer() -> void:
	retreat_timer.start(randf())


func _on_IdleWaitTimer_timeout() -> void:
	enemy_move_states.call_deferred("set_state", "move")


func _on_Hitbox_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if enemy_move_states.state != "attack":
		enemy_move_states.call_deferred("set_state", "attack")


func _on_RetreatTimer_timeout() -> void:
	enemy_move_states.call_deferred("set_state", "idle")
