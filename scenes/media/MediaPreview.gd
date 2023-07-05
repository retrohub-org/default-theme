extends Button

@onready var n_texture := %Texture2D

var texture : Texture2D:
	get:
		return n_texture.texture
	set(value):
		n_texture.texture = value

var type : String

func tts_text(focused: Control) -> String:
	return type + " Button"
