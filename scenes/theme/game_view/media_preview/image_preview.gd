extends Button

signal media_pressed(media, type)

var media : Texture2D
var type : RetroHubMedia.Type

func create(media: Resource, type: RetroHubMedia.Type):
	self.type = type
	self.media = media
	
	icon = media

func _on_toggled(button_pressed):
	if button_pressed:
		media_pressed.emit(media, type)
