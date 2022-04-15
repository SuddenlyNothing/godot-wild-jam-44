extends AudioStreamPlayer2D

export(Array, AudioStream) var audio

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	play()


func play(from_position: float = 0.0) -> void:
	rng.randomize()
	if stream is AudioStreamRandomPitch:
		stream.audio_stream = audio[rng.randi_range(0, len(audio) - 1)]
	else:
		stream = audio[rng.randi_range(0, len(audio) - 1)]
	.play(from_position)
