extends Button

signal media_pressed(media, type)

var media : VideoStream
var type : RetroHubMedia.Type

func create(_media: Resource, _type: RetroHubMedia.Type):
	self.type = _type
	self.media = _media

func _on_toggled(_pressed: bool):
	if _pressed:
		media_pressed.emit(media, type)
