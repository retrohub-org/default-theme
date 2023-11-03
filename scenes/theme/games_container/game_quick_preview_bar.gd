extends HBoxContainer

@onready var n_logo := %Logo
@onready var n_name := %Name
@onready var n_rating := %Rating
@onready var n_age_rating_container := %AgeRatingContainer
@onready var n_stats_play_count := %StatsPlayCount
@onready var n_stats_play_date := %StatsPlayDate

var data : RetroHubGameData

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHubMedia.media_loaded.connect(_on_media_loaded)
	RetroHubConfig.game_data_updated.connect(
		func(_data: RetroHubGameData):
			if self.data == _data and is_visible_in_tree():
				_on_game_preview_selected(_data, false)
	)

func _on_media_loaded(media_data: RetroHubGameMediaData, game_data: RetroHubGameData, _types: int):
	if game_data == data and media_data.logo:
		n_logo.texture = media_data.logo


func _on_game_preview_selected(_data: RetroHubGameData, show_in_ui: bool):
	self.data = _data

	n_name.text = _data.name
	n_name.autowrap_mode = TextServer.AUTOWRAP_WORD
	n_name.size_flags_vertical |= SIZE_EXPAND
	n_rating.value = _data.rating
	for child in n_age_rating_container.get_children():
		child.queue_free()
	n_age_rating_container.add_child(RegionUtils.localize_age_rating(_data.age_rating))
	n_stats_play_count.text = str(_data.play_count) if _data.play_count > 0 else "never played before"
	var last_play_date := RegionUtils.localize_date(_data.last_played) if not _data.last_played.is_empty() else "never played before"
	n_stats_play_date.text = last_play_date

	# If name occupies only one line, don't make it expand, letting rating stick close
	# to the text and look better.
	if n_name.get_line_count() == 1:
		n_name.autowrap_mode = TextServer.AUTOWRAP_OFF
		n_name.size_flags_vertical &= ~SIZE_EXPAND
		

	n_logo.texture = null
	if _data.has_media:
		RetroHubMedia.retrieve_media_data_async(_data, RetroHubMedia.Type.LOGO)
	if show_in_ui:
		RetroHub.set_curr_game_data(_data)
