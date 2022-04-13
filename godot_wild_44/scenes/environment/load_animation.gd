tool
extends TextureRect

export(Array, Texture) var textures
export(int) var fps := 10
export(bool) var use setget set_textures


func set_textures(val: bool) -> void:
	use = val
	if textures.empty():
		printerr("Textures can't be empty")
		return
	texture = AnimatedTexture.new()
	texture.fps = fps
	texture.frames = textures.size()
	for i in range(textures.size()):
		texture.set_frame_texture(i, textures[i])
