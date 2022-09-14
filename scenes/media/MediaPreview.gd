extends Button

onready var n_texture := $"%Texture"

var texture : Texture setget set_texture, get_texture
var type : String

func set_texture(texture: Texture):
	n_texture.texture = texture

func get_texture() -> Texture:
	return n_texture.texture
