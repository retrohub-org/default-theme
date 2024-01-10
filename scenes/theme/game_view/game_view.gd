extends Control

var data : RetroHubGameData

signal preview_ready
signal on_back_pressed

@onready var n_media_root := %Media
@onready var n_data_root := %Data
@onready var n_back := %Back

@onready var n_keyboard_focus_btn := %KeyboardFocusButton
@onready var n_preview_load_timer := %PreviewLoadTimer

@onready var window_size := get_viewport_rect().size

var media_expanded := false

func _ready():
	get_viewport().size_changed.connect(func():
		window_size = get_viewport_rect().size
	)

func _input(event):
	if not visible: return
	if event.is_action_released("rh_back"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()

func _gui_input(event):
	if event is InputEventMouseButton:
		if n_media_root.get_rect().has_point(event.position) and \
			event.pressed and event.button_index == MOUSE_BUTTON_LEFT and \
			not media_expanded:
				accept_event()
				_on_media_focus_entered()
		if n_data_root.get_rect().has_point(event.position) and \
			event.pressed and event.button_index == MOUSE_BUTTON_LEFT and \
			media_expanded and not get_viewport().is_input_handled():
				accept_event()
				_on_data_focus_entered()

func _on_game_pressed(_data: RetroHubGameData, _preview: Control):
	self.data = _data

	_on_data_focus_entered(0.0)
	n_data_root.game_data = _data
	n_media_root.game_data = _data
	if RetroHubConfig.config.accessibility_screen_reader_enabled:
		n_data_root.set_prev_focus("../Back")
	else:
		n_data_root.set_bottom_focus("../Back")
	n_preview_load_timer.start()

func _on_back_pressed():
	if media_expanded:
		_on_data_focus_entered()
	else:
		on_back_pressed.emit()

func mute_media():
	n_media_root.mute_media()

func free_media():
	n_media_root.free_media()

func _on_media_focus_entered():
	if media_expanded: return

	# Give media more by expanding it's size
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)

	# Find minimum size for data, then give the rest to media
	var min_size : Vector2 = n_data_root.get_minimum_size()
	var screen_size := get_viewport().get_visible_rect().size
	var media_size := Vector2(screen_size.x, screen_size.y - min_size.y)
	n_media_root.allocated_size = media_size

	tween.tween_property(n_media_root, "size:y", media_size.y, 0.3)
	tween.tween_property(n_data_root, "position:y", media_size.y, 0.3)

	# Re-order media elements
	n_media_root.animate_enter(0.3)
	
	# Make data unfocusable
	n_data_root.focus_mode = FOCUS_NONE
	n_keyboard_focus_btn.focus_mode = FOCUS_NONE
	n_back.focus_neighbor_bottom = ""

	media_expanded = true

func _on_data_focus_entered(time := 0.3, grab_focus := true):
	# Restore original layout
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	var ratio : float = 1.0 - n_data_root.get_desired_ratio()

	tween.tween_property(n_media_root, "size:y", window_size.y * ratio, time)
	tween.tween_property(n_data_root, "position:y", window_size.y * ratio, time)

	# Re-order media elements
	n_media_root.animate_exit(time)
	
	# Give expected height to data node, so it can resize
	n_data_root.set_expected_height((1.0 - ratio) * window_size.y)

	# Make play grab focus
	n_data_root.focus_mode = FOCUS_ALL
	n_keyboard_focus_btn.focus_mode = FOCUS_ALL
	n_back.focus_neighbor_bottom = "../Media/KeyboardFocusButton"
	if grab_focus and get_viewport().gui_get_focus_owner() != n_back:
		n_data_root.grab_focus()

	media_expanded = false

func _grab_play_button():
	n_data_root.grab_focus()


func _on_preview_load_timer_timeout():
	preview_ready.emit()


func _on_media_media_ready():
	preview_ready.emit()


func _on_keyboard_focus_button_pressed():
	_on_media_focus_entered()


func _on_data_resize_needed():
	if not media_expanded:
		_on_data_focus_entered(0.3, false)
