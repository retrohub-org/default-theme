extends VBoxContainer

@onready var n_game_preview = %GamePreview
@onready var n_label := %Label

var game_data : RetroHubGameData:
	set(value):
		game_data = value
		n_game_preview.game_data = game_data

		n_label.text = game_data.name
