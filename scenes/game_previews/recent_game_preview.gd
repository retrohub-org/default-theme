extends VBoxContainer

signal game_preview_selected(data: RetroHubGameData, select_on_ui: bool)
signal game_pressed(data: RetroHubGameData)

@onready var n_button := %Button
@onready var n_label := %Label

var game_data : RetroHubGameData:
	set(value):
		game_data = value

		n_label.text = game_data.name
		if game_data.has_media:
			RetroHubMedia.retrieve_media_data_async(game_data, RetroHubMedia.Type.TITLE_SCREEN)

func _ready():
	RetroHubMedia.media_loaded.connect(_on_media_loaded)

func _on_media_loaded(media: RetroHubGameMediaData, data: RetroHubGameData, types: int):
	if self.game_data != data: return

	if media.title_screen:
		n_button.icon = media.title_screen

func _on_mouse_entered():
	game_preview_selected.emit(game_data, false)
	get_tree().call_group("global_signal(on_game_preview_selected)", "_on_game_preview_selected", game_data, false)


func _on_focus_entered():
	game_preview_selected.emit(game_data, true)
	get_tree().call_group("global_signal(on_game_preview_selected)", "_on_game_preview_selected", game_data, true)


func _on_pressed():
	game_pressed.emit(game_data)
	get_tree().call_group("global_signal(on_game_pressed)", "_on_game_pressed", game_data)
