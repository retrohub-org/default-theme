extends Node

@onready var n_no_games := %NoGames
@onready var n_bottom_info := %BottomInfo
@onready var n_accept_icon := %AcceptIcon
@onready var n_more_info_icon := %MoreInfoIcon
@onready var n_sorting := %Sorting
@onready var n_sort_filter_popup := %SortFilterPopup

# _ready function, called everytime the theme is loaded, and only once
func _ready():
	n_bottom_info.visible = false
	RetroHub.game_receive_start.connect(_on_game_receive_start)
	RetroHubConfig.config_updated.connect(_on_config_updated)
	if $NoGames/Label.focus_mode == Control.FOCUS_ALL:
		$NoGames/Label.grab_focus()

func _unhandled_input(event):
	if event.is_action_pressed("rh_theme_menu"):
		n_sort_filter_popup.last_focused_control = get_viewport().gui_get_focus_owner()
		n_sort_filter_popup.popup()

func _on_game_receive_start():
	TTS.stop()
	remove_child(n_no_games)
	n_no_games.queue_free()
	n_bottom_info.visible = true
	n_accept_icon.global_position = Vector2.ZERO
	n_more_info_icon.global_position = Vector2.ZERO

func _on_config_updated(key: String, old, new):
	if key == ConfigData.KEY_GAMES_DIR:
		RetroHub.request_theme_reload()


func _on_GamesGridManager_expensive_sort():
	n_sorting.visible = true


func _on_GamesGridManager_sort_over():
	n_sorting.visible = false

func tts_text(focused: Control) -> String:
	if n_no_games and focused == $NoGames/HBoxContainer:
		return $NoGames/HBoxContainer/Label.text + " " \
			+ $NoGames/HBoxContainer/ControllerTextureRect.get_tts_string() + " " \
			+ $NoGames/HBoxContainer/Label2.text
	return ""
