extends BaseLevel


func enter_event(n: int) -> void:
	match n:
		6:
			MusicPlayer.fade_in()
			dynamic_camera.smoothing_speed = 1
			dynamic_camera.set_zoom(Vector2.ONE * 0.35)
			dynamic_camera.follow_node = $YSort/WaveParent/WaveHandler4/PenguinSpawner
			yield(get_tree().create_timer(2), "timeout")
			dynamic_camera.set_zoom(Vector2.ONE * 0.8)
			dynamic_camera.follow_node = $Position2D


func exit_event(n: int) -> void:
	match n:
		6:
			dynamic_camera.set_zoom(Vector2.ONE / 2)
			dynamic_camera.smoothing_speed = 5
			dynamic_camera.follow_node = player
			MusicPlayer.fade_out()
