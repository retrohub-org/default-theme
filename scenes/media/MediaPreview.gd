extends Button

@onready var n_texture := $"%Texture2D"

var texture : Texture2D: get = get_texture, set = set_texture
var type : String

func set_texture(texture: Texture2D):
	n_texture.texture = texture

func get_texture() -> Texture2D:
	return n_texture.texture

func tts_text(focused: Control) -> String:
	return type + " Button"
