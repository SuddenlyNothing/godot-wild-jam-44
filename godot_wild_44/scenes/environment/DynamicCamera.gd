extends Camera2D

var follow_node: Node2D

onready var shake_timer := $ShakeTimer
onready var t := $Tween


func _process(_delta: float) -> void:
	if is_instance_valid(follow_node):
		position = follow_node.position
	if not shake_timer.is_stopped():
		offset = Vector2((randf() - 0.5) * 4, (randf() - 0.5) * 4)


func set_zoom(val: Vector2):
	t.remove_all()
	t.interpolate_property(self, "zoom", zoom, val, 1)
	t.start()


func shake() -> void:
	shake_timer.start()


func set_player(val) -> void:
	follow_node = val


func _on_ShakeTimer_timeout() -> void:
	offset = Vector2()
