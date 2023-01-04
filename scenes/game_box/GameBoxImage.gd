extends Button

signal show_game_info(game_data)

onready var n_media := $"%Media"
onready var n_label := $"%Label"
onready var n_more_info_root := $"%MoreInfoRoot"
onready var n_play_container := $"%PlayContainer"

var game_data : RetroHubGameData setget set_game_data

func set_game_data(_game_data: RetroHubGameData):
	game_data = _game_data
	n_label.text = game_data.name

func _ready():
	RetroHub.connect("app_returning", self, "_on_app_returning")
	RetroHubMedia.connect("media_loaded", self, "_on_media_loaded")

	RetroHubConfig.connect("game_data_updated", self, "_on_game_data_updated")

func _on_app_returning(_unused: RetroHubSystemData, data: RetroHubGameData):
	if game_data == data:
		print("Grabbing focus")
		grab_focus()
		_on_GameBoxImage_focus_entered()

func _on_media_loaded(media_data: RetroHubGameMediaData, _game_data: RetroHubGameData, types: int):
	if game_data == _game_data and not n_media.texture:
		if types == RetroHubMedia.Type.TITLE_SCREEN:
			if media_data.title_screen:
				n_media.texture = media_data.title_screen
			else:
				RetroHubMedia.retrieve_media_data_async(game_data, RetroHubMedia.Type.SCREENSHOT)
		elif types == RetroHubMedia.Type.SCREENSHOT:
			if media_data.screenshot:
				n_media.texture = media_data.screenshot
			else:
				RetroHubMedia.retrieve_media_data_async(game_data, RetroHubMedia.Type.LOGO)
		elif types == RetroHubMedia.Type.LOGO and media_data.logo:
			n_media.texture = media_data.logo

func _on_game_data_updated(data: RetroHubGameData):
	if game_data == data:
		set_game_data(game_data)

func _on_GameBoxImage_pressed():
	RetroHub.launch_game()

func _on_GameBoxImage_focus_entered():
	RetroHub.set_curr_game_data(game_data)
	n_more_info_root.visible = true
	n_play_container.visible = true

func _on_GameBoxImage_focus_exited():
	n_more_info_root.visible = false
	n_play_container.visible = false

func _gui_input(event):
	if event.is_action_pressed("rh_major_option"):
		_on_MoreInfo_pressed()

func _on_GameBoxImage_visibility_changed():
	if visible and not n_media.texture:
		RetroHubMedia.retrieve_media_data_async(game_data, RetroHubMedia.Type.TITLE_SCREEN)
	else:
		RetroHubMedia.cancel_media_data_async(game_data)
		n_media.texture = null

func _on_MoreInfo_pressed():
	emit_signal("show_game_info", game_data)
