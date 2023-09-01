extends VBoxContainer

@onready var n_game_preview = %GamePreview
@onready var n_label := %Label

var game_data : RetroHubGameData:
	set(value):
		game_data = value
		n_game_preview.game_data = game_data

		n_label.text = game_data.name

func _ready():
	RetroHubConfig.game_data_updated.connect(func(game_data: RetroHubGameData):
		if self.game_data == game_data and is_visible_in_tree():
			self.game_data = game_data
	)

func grab_focus():
	n_game_preview.grab_focus()

func set_focus_neighbor_bottom(path: NodePath):
	n_game_preview.focus_neighbor_bottom = path

func set_focus_neighbor_top(path: NodePath):
	n_game_preview.focus_neighbor_top = path
