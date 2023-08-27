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

func _on_media_loaded(media_data: RetroHubGameMediaData, game_data: RetroHubGameData, types: int):
	if game_data == data and media_data.logo:
		n_logo.texture = media_data.logo


func _on_game_preview_selected(data: RetroHubGameData, show_in_ui: bool):
	self.data = data

	n_name.text = data.name
	n_name.autowrap_mode = TextServer.AUTOWRAP_WORD
	n_name.size_flags_vertical |= SIZE_EXPAND
	n_rating.value = data.rating
	for child in n_age_rating_container.get_children():
		child.queue_free()
	n_age_rating_container.add_child(RegionUtils.localize_age_rating(data.age_rating))
	n_stats_play_count.text = str(data.play_count) if data.play_count > 0 else "never played before"
	var last_play_date := RegionUtils.localize_date(data.last_played) if not data.last_played.is_empty() else "never played before"
	n_stats_play_date.text = last_play_date

	# If name occupies only one line, don't make it expand, letting rating stick close
	# to the text and look better.
	if n_name.get_line_count() == 1:
		n_name.autowrap_mode = TextServer.AUTOWRAP_OFF
		n_name.size_flags_vertical &= ~SIZE_EXPAND
		

	n_logo.texture = null
	if data.has_media:
		RetroHubMedia.retrieve_media_data_async(data, RetroHubMedia.Type.LOGO)
	if show_in_ui:
		RetroHub.set_curr_game_data(data)
