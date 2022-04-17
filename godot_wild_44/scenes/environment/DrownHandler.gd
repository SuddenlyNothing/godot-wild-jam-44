extends Area2D

var queue_drown := {}
var bodies_in_area := {}

onready var ice_tiles := get_child(0)


func _ready() -> void:
	ice_tiles.connect("ignore_updated", self, "_on_ignore_updated")


func _on_ignore_updated() -> void:
	if not ice_tiles.ignore:
		return
	for i in queue_drown:
		if not i in bodies_in_area and is_instance_valid(i):
			i.drown()
	queue_drown.clear()


func _on_DrownHandler_body_entered(body: Node) -> void:
	if not body.is_in_group("drownable"):
		return
	bodies_in_area[body] = 0
	if ice_tiles.ignore:
		queue_drown.erase(body)


func _on_DrownHandler_body_exited(body: Node) -> void:
	if not body.is_in_group("drownable"):
		return
	bodies_in_area.erase(body)
	if ice_tiles.ignore:
		queue_drown[body] = 0
	else:
		body.drown()
