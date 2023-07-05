extends VBoxContainer

@onready var n_aspect_ratio_cnt := $"%AspectRatioContainer"
@onready var n_player := $"%Player"
@onready var n_play_pause := $"%PlayPause"
@onready var n_progress := $"%Progress"
@onready var n_progress_updater := $"%ProgressUpdater"

var video_len : float
var dragging := false
var drag_was_paused : bool

func set_video(video: VideoStream):
	n_player.stream = video
	if n_player.get_video_texture():
		n_aspect_ratio_cnt.ratio = n_player.get_video_texture().get_size().aspect()
	reset()

func reset():
	n_player.stop()
	n_player.stream_position = -1
	video_len = n_player.stream_position
	n_player.stream_position = 0
	n_player.paused = true
	if not RetroHubConfig.config.accessibility_screen_reader_enabled:
		n_player.play()
	n_progress.max_value = video_len
	n_play_pause.button_pressed = false

func play():
	n_progress_updater.start()
	n_player.paused = false
	n_play_pause.button_pressed = true

func pause():
	n_progress_updater.stop()
	n_player.paused = true
	n_play_pause.button_pressed = false

func stop():
	n_progress_updater.stop()
	n_player.stop()
	n_play_pause.button_pressed = false

func _on_PlayPause_toggled(button_pressed):
	play() if button_pressed else pause()

func _on_Progress_drag_started():
	drag_was_paused = n_player.paused
	dragging = true
	n_player.paused = true

func _on_Progress_value_changed(value):
	if dragging:
		n_player.stream_position = value

func _on_Progress_drag_ended(value_changed):
	dragging = false
	n_player.paused = drag_was_paused

func _on_ProgressUpdater_timeout():
	if not dragging:
		n_progress.value = n_player.stream_position


func _on_Player_finished():
	# Loop
	n_player.stream_position = 0
	n_player.play()


func _on_PlayPause_focus_entered():
	n_play_pause.modulate = Color("aafff9")


func _on_PlayPause_focus_exited():
	n_play_pause.modulate = Color("ffffff")

func tts_text(focused: Control):
	if focused == n_play_pause:
		if n_play_pause.pressed:
			return "Pause video"
		else:
			return "Play video"
	return ""
