extends Window

signal setting_changed(key, value)

@onready var n_tabs := %TabBar
@onready var n_sort_by := %SortBy
@onready var n_sort_reverse := %SortReverse
@onready var n_filter_show := %FilterShow
@onready var n_preview_mode := %PreviewMode
@onready var n_preview_video := %PreviewVideo

var last_focused_control : Control = null

func _ready():
	RetroHubConfig.theme_config_ready.connect(_on_theme_config_ready)
	# Prevent close buttons from receiving focus
	# get_close_button().focus_mode = Window.FOCUS_NONE

func _unhandled_input(event):
	get_viewport().set_input_as_handled()
	if event.is_action_pressed("rh_theme_menu"):
		hide()
		if is_instance_valid(last_focused_control):
			last_focused_control.grab_focus()
	elif event.is_action_pressed("rh_left_shoulder"):
		if n_tabs.current_tab == 0:
			n_tabs.current_tab = n_tabs.get_tab_count() - 1
		else:
			n_tabs.current_tab -= 1
		set_focus()
	elif event.is_action_pressed("rh_right_shoulder"):
		if n_tabs.current_tab == n_tabs.get_tab_count() - 1:
			n_tabs.current_tab = 0
		else:
			n_tabs.current_tab += 1
		set_focus()

func _on_theme_config_ready():
	n_sort_by.selected = RetroHubConfig.get_theme_config("sort_mode", 0)
	n_sort_reverse.set_pressed_no_signal(RetroHubConfig.get_theme_config("sort_reversed", false))
	n_filter_show.selected = RetroHubConfig.get_theme_config("filter_mode", 0)
	n_preview_mode.set_pressed_no_signal(RetroHubConfig.get_theme_config("preview_mode", 0))
	n_preview_video.button_pressed = RetroHubConfig.get_theme_config("preview_video", true)

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
	RetroHubConfig.set_theme_config("preview_mode", n_preview_mode.get_item_id(index))
	emit_signal("setting_changed", "preview_mode", n_preview_mode.get_item_id(index))

func _on_PreviewVideo_toggled(button_pressed: bool):
	RetroHubConfig.set_theme_config("preview_video", button_pressed)
	emit_signal("setting_changed", "preview_video", button_pressed)

func set_focus():
	match n_tabs.current_tab:
		0:
			n_sort_by.grab_focus()
		1:
			n_filter_show.grab_focus()
		2:
			n_preview_mode.grab_focus()


func _on_about_to_popup():
	set_focus()
