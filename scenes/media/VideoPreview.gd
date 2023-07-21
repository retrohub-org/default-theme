extends Button

var video : VideoStream: set = set_video

func set_video(_video: VideoStream):
	video = _video

func tts_text(focused: Control) -> String:
	return "Video Button"
