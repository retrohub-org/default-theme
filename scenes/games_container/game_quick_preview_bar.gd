extends HBoxContainer

@onready var n_logo := %Logo
@onready var n_name := %Name
@onready var n_rating := %Rating
@onready var n_stats_play_count := %StatsPlayCount
@onready var n_stats_play_date := %StatsPlayDate

@onready var play_count_base_text = n_stats_play_count.text
@onready var play_date_base_text = n_stats_play_date.text

var data : RetroHubGameData

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHubMedia.media_loaded.connect(_on_media_loaded)

func _on_media_loaded(media_data: RetroHubGameMediaData, game_data: RetroHubGameData, types: int):
	if game_data == data and media_data.logo:
		n_logo.texture = media_data.logo


func _on_game_preview_selected(data: RetroHubGameData, show_in_ui: bool):
	self.data = data

	n_name.text = data.name
	n_rating.value = data.rating
	n_stats_play_count.text = play_count_base_text % data.play_count
	var last_play_date = RegionUtils.localize_date(data.last_played) if not data.last_played.is_empty() else "never"
	n_stats_play_date.text = play_date_base_text % last_play_date

	n_logo.texture = null
	RetroHubMedia.retrieve_media_data_async(data, RetroHubMedia.Type.LOGO)
	if show_in_ui:
		RetroHub.set_curr_game_data(data)
