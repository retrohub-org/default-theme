extends HBoxContainer

onready var n_game_logo := $"%GameLogo"
onready var n_num_times_played := $"%NumTimesPlayed"
onready var n_last_played := $"%LastPlayed"

var game_data : RetroHubGameData
var tmp_game_data : RetroHubGameData

func _ready():
	RetroHubMedia.connect("media_loaded", self, "_on_media_loaded")

func _on_media_loaded(media_data: RetroHubGameMediaData, game_data: RetroHubGameData, _unused: int):
	if game_data == tmp_game_data:
		n_game_logo.texture = media_data.logo


func _on_GamesGridManager_game_selected(_game_data):
	game_data = _game_data
	n_num_times_played.text = str(game_data.play_count)
	n_last_played.text = "never" if not game_data.last_played else RegionUtils.localize_date(game_data.last_played)
	if game_data.has_media:
		tmp_game_data = RetroHubGameData.new()
		tmp_game_data.path = game_data.path
		tmp_game_data.name = game_data.name
		tmp_game_data.system_path = game_data.system_path
		tmp_game_data.has_media = true
		RetroHubMedia.retrieve_media_data_async(tmp_game_data, RetroHubMedia.Type.LOGO)
	else:
		n_game_logo.texture = null
