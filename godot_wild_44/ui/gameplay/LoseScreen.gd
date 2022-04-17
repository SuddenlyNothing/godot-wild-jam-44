extends Control

signal retry_wave_pressed
signal restart_pressed

onready var t_elements := [
	$M,
	$M/M/V/Label,
	$M/M/V/V/H/Retry,
	$M/M/V/V/H/Restart,
	$M/M/V/V/H2/Settings,
	$M/M/V/V/H2/Menu,
]
onready var t := $Tween


func enter() -> void:
	var delay := 0.0
	for e in t_elements:
		var start_pos: float = e.rect_global_position.y
		e.modulate.a = 0
		t.interpolate_property(e, "rect_global_position:y", start_pos + 100, start_pos,
				0.3, Tween.TRANS_SINE, Tween.EASE_OUT, delay)
		t.interpolate_property(e, "modulate:a", 0, 1, 0.3, Tween.TRANS_SINE, Tween.EASE_OUT, delay)
		delay += 0.1
	t.start()
	call_deferred("show")


func exit() -> void:
	hide()


func _on_Settings_pressed() -> void:
	OptionsMenu.set_active(true)


func _on_Retry_pressed() -> void:
	emit_signal("retry_wave_pressed")
	exit()


func _on_Restart_pressed() -> void:
	emit_signal("restart_pressed")
	exit()
