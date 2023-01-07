extends WindowDialog

signal setting_changed(key, value)

onready var n_tabs := $"%Tabs"
onready var n_sort_by := $"%SortBy"
onready var n_sort_reverse := $"%SortReverse"
onready var n_filter_show := $"%FilterShow"
onready var n_preview_mode := $"%PreviewMode"
onready var n_preview_video := $"%PreviewVideo"

var last_focused_control : Control = null

func _ready():
	load_settings()
	# Prevent close buttons from receiving focus
	get_close_button().focus_mode = FOCUS_NONE

func _unhandled_input(event):
	if visible:
		get_tree().set_input_as_handled()
		if event.is_action_pressed("rh_minor_option"):
			hide()
			if is_instance_valid(last_focused_control):
				last_focused_control.grab_focus()
		elif event.is_action_pressed("rh_left_shoulder"):
			if n_tabs.current_tab == 0:
				n_tabs.current_tab = n_tabs.get_tab_count() - 1
			else:
				n_tabs.current_tab -= 1
			grab_focus()
		elif event.is_action_pressed("rh_right_shoulder"):
			if n_tabs.current_tab == n_tabs.get_tab_count() - 1:
				n_tabs.current_tab = 0
			else:
				n_tabs.current_tab += 1
			grab_focus()
	elif event.is_action_pressed("rh_minor_option"):
		last_focused_control = get_focus_owner()
		popup()

func load_settings():
	n_sort_by.selected = RetroHubConfig.get_theme_config("sort_mode", 0)
	n_sort_reverse.set_pressed_no_signal(RetroHubConfig.get_theme_config("sort_reversed", false))
	n_filter_show.selected = RetroHubConfig.get_theme_config("filter_mode", 0)
	n_preview_mode.set_pressed_no_signal(RetroHubConfig.get_theme_config("preview_mode", 0))
	n_preview_video.pressed = RetroHubConfig.get_theme_config("preview_video", true)

func _on_SortBy_item_selected(index: int):
	RetroHubConfig.set_theme_config("sort_mode", index)
	emit_signal("setting_changed", "sort_mode", index)

func _on_SortReverse_toggled(button_pressed: bool):
	RetroHubConfig.set_theme_config("sort_reversed", button_pressed)
	emit_signal("setting_changed", "sort_reversed", button_pressed)

func _on_FilterShow_item_selected(index: int):
	RetroHubConfig.set_theme_config("filter_mode", index)
	emit_signal("setting_changed", "filter_mode", index)

func _on_PreviewMode_item_selected(index: int):
	RetroHubConfig.set_theme_config("preview_mode", index)
	emit_signal("setting_changed", "preview_mode", index)

func _on_PreviewVideo_toggled(button_pressed: bool):
	RetroHubConfig.set_theme_config("preview_video", button_pressed)
	emit_signal("setting_changed", "preview_video", button_pressed)

func grab_focus():
	match n_tabs.current_tab:
		0:
			n_sort_by.grab_focus()
		1:
			n_filter_show.grab_focus()
		2:
			n_preview_mode.grab_focus()
