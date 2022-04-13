extends Area2D



func _on_DrownHandler_area_exited(area: Area2D) -> void:
	if not area.is_in_group("drownable"):
		return
	area.drown()


func _on_DrownHandler_body_exited(body: Node) -> void:
	if not body.is_in_group("drownable"):
		return
	body.drown()
