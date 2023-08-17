extends Control

var Utils := preload("res://Utils.gd").new()

var data : RetroHubGameData

@onready var n_name := %Name
@onready var n_logo := %Logo
@onready var n_image := %ImagePreview

@onready var n_play_date := %PlayDate
@onready var n_play_count := %PlayCount
@onready var n_num_players := %NumPlayers
@onready var n_rating := %Rating
@onready var n_favorite := %Favorite
@onready var n_developer := %Developer
@onready var n_publisher := %Publisher
@onready var n_genres := %Genres
@onready var n_release_date := %ReleaseDate
@onready var n_description := %Description

@onready var n_base_text := {
	n_play_date: n_play_date.text,
	n_play_count: n_play_count.text,
	n_num_players: n_num_players.text,
	n_developer: n_developer.text,
	n_publisher: n_publisher.text,
	n_genres: n_genres.text,
	n_release_date: n_release_date.text,
}

func _ready():
	RetroHubMedia.media_loaded.connect(_on_media_loaded)

func _on_media_loaded(media: RetroHubGameMediaData, data: RetroHubGameData, types: int):
	if not visible or self.data != data: return
	if media.logo:
		n_logo.texture = media.logo
		n_logo.visible = true
		n_name.visible = false
	if media.screenshot:
		n_image.texture = media.screenshot
		n_image.texture_filter = TEXTURE_FILTER_NEAREST if Utils.is_low_res_system(data.system) else TEXTURE_FILTER_LINEAR

func _on_game_pressed(data: RetroHubGameData):
	visible = true
	self.data = data
	
	n_name.text = data.name
	n_description.text = data.description
	n_play_date.text = n_base_text[n_play_date] % RegionUtils.localize_date(data.last_played) if not data.last_played.is_empty() else "never"
	n_play_count.text = n_base_text[n_play_count] % data.play_count
	n_num_players.text = n_base_text[n_num_players] % data.num_players
	n_developer.text = n_base_text[n_developer] % data.developer
	n_publisher.text = n_base_text[n_publisher] % data.publisher
	n_genres.text = n_base_text[n_genres] % data.genres[0] if not data.genres.is_empty() else "unknown"
	n_release_date.text = n_base_text[n_release_date] % RegionUtils.localize_date(data.release_date)
	
	n_logo.visible = false
	n_image.texture = null
	
	if data.has_media:
		RetroHubMedia.retrieve_media_data_async(data, RetroHubMedia.Type.ALL, true)

func _on_back_pressed():
	visible = false
