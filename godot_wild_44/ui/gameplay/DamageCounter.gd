extends Node2D

onready var t := $Tween
onready var label := $Label

var text: String


func _ready() -> void:
	label.text = text
	t.interpolate_property(label, "rect_scale", Vector2.ONE * 2, Vector2.ONE / 2, 0.5,
			Tween.TRANS_QUAD, Tween.EASE_OUT)
	t.interpolate_property(label, "rect_position:y", label.rect_position.y,
			label.rect_position.y - 50, 0.5)
	t.interpolate_property(label, "modulate:a", 1, 0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN)
	t.start()


func _on_Tween_tween_all_completed() -> void:
	queue_free()
