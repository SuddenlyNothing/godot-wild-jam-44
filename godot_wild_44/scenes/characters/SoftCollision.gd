extends Area2D

export(int) var push_acc := 200
export(int) var friction := 500
var push_vel := Vector2()
var collide_area : Area2D


func _physics_process(delta: float) -> void:
	if collide_area == null:
		if not push_vel:
			return
		var friction_amount := friction * delta
		if push_vel.length() <= friction_amount:
			push_vel = Vector2()
		else:
			push_vel -= friction * delta * push_vel.normalized()
	else:
		push_vel += push_acc * delta * collide_area.global_position.direction_to(global_position)


func get_push_velocity() -> Vector2:
	return push_vel


func _on_SoftCollision_area_entered(area: Area2D) -> void:
	if not area.is_in_group("soft_collision") or collide_area != null:
		return
	collide_area = area


func _on_SoftCollision_area_exited(area: Area2D) -> void:
	if area != collide_area:
		return
	collide_area = null
