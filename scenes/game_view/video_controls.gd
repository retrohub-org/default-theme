extends Panel

@onready var n_play_pause := %PlayPause
@onready var n_time := %Time
@onready var n_time_label := %TimeLabel
@onready var n_sound := %Sound
@onready var n_volume_popup := %VolumePopup
@onready var n_volume_slider := %VolumeSlider

@onready var n_time_timer := %TimeTimer
@onready var n_volume_hide_timer := %VolumeHideTimer

@onready var time_label_text : String = n_time_label.text
var max_time : float

func _ready():
	n_time_timer.stop()

var video_player : VideoStreamPlayer:
	set(value):
		video_player = value

		setup()

func setup():
	# Hack to find video length on kidrigger's addon.
	video_player.stream_position = -1
	max_time = video_player.stream_position
	video_player.stream_position = 0

	n_play_pause.button_pressed = false
	n_time.max_value = max_time
	n_time.set_value_no_signal(0)
	set_time_label()
	set_volume(n_volume_slider.value if not n_sound.button_pressed else 0)
	n_volume_popup.visible = false
	video_player.play()
	n_time_timer.start()

func update_stream_position():
	if video_player:
		n_time.value = video_player.stream_position

func set_time_label():
	if not RetroHub.is_main_app(): return

	var curr_time = "%02d:%02d" % [floor(n_time.value / 60), floor(fmod(n_time.value, 60))]
	var total_time = "%02d:%02d" % [floor(max_time / 60), floor(fmod(max_time, 60))]

	n_time_label.text = time_label_text % [curr_time, total_time]

func set_volume(value: float):
	video_player.volume_db = linear_to_db(value)


func _on_play_pause_toggled(button_pressed):
	video_player.paused = button_pressed

var was_paused : bool

func _on_time_drag_started():
	was_paused = video_player.paused
	video_player.paused = true
	n_time_timer.stop()


func _on_time_drag_ended(value_changed):
	video_player.stream_position = n_time.value
	video_player.paused = false
	var volume = video_player.volume
	video_player.volume = 0
	await get_tree().physics_frame
	await get_tree().physics_frame
	video_player.paused = was_paused
	video_player.volume = volume
	n_time_timer.start()

func show_volume_popup():
	n_volume_hide_timer.stop()
	n_volume_popup.visible = true

func _on_sound_mouse_exited():
	n_volume_hide_timer.start()
	print("Exit sound, tick...")


func _on_sound_focus_exited():
	n_volume_popup.visible = false


func _on_volume_popup_mouse_exited():
	if not n_volume_popup.get_global_rect().has_point(get_global_mouse_position()):
		n_volume_hide_timer.start()
		print("Exit popup, tick...")


func _on_volume_popup_mouse_entered():
	n_volume_hide_timer.stop()
	print("Stop ticking")


func _on_volume_slider_value_changed(value):
	set_volume(value)
	n_sound.set_pressed_no_signal(false)


func _on_volume_hide_timer_timeout():
	n_volume_popup.visible = false


func _on_sound_toggled(button_pressed):
	if button_pressed:
		set_volume(0)
	else:
		set_volume(n_volume_slider.value)


func _on_visibility_changed():
	if not n_time_timer: return
	if visible:
		n_time_timer.start()
	else:
		n_time_timer.stop()


func _on_time_value_changed(value):
	set_time_label()

