extends Control

var is_credits_visible := false

onready var t := $Tween
onready var credits := $Credits


func _ready() -> void:
	MusicPlayer.play("menu")


func _on_Settings_pressed() -> void:
	OptionsMenu.set_active(true)


func _on_Credits_pressed() -> void:
	if t.is_active():
		return
	if is_credits_visible:
		var delay := 0.0
		for child in credits.get_children():
			var start_pos: float = child.rect_global_position.y
			t.interpolate_property(child, "rect_global_position:y", start_pos,
					start_pos + 100, 0.3, Tween.TRANS_SINE, Tween.EASE_OUT, delay)
			t.interpolate_property(child, "modulate:a", 1, 0, 0.3, Tween.TRANS_SINE,
					Tween.EASE_OUT, delay)
			delay += 0.1
		t.start()
	else:
		var delay := 0.0
		for child in credits.get_children():
			var start_pos: float = child.rect_global_position.y
			child.modulate.a = 0
			t.interpolate_property(child, "rect_global_position:y", start_pos,
					start_pos - 100, 0.3, Tween.TRANS_SINE, Tween.EASE_OUT, delay)
			t.interpolate_property(child, "modulate:a", 0, 1, 0.3, Tween.TRANS_SINE,
					Tween.EASE_OUT, delay)
			delay += 0.1
		t.start()
	is_credits_visible = not is_credits_visible
