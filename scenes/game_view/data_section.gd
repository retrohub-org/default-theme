extends Control

@onready var n_play := %Play
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

var game_data : RetroHubGameData:
	set(value):
		game_data = value
		populate()

func populate():
	n_description.text = game_data.description
	n_play_date.text = n_base_text[n_play_date] % (RegionUtils.localize_date(game_data.last_played) if not game_data.last_played.is_empty() else "never")
	n_play_count.text = n_base_text[n_play_count] % game_data.play_count
	n_num_players.text = n_base_text[n_num_players] % game_data.num_players
	n_rating.value = game_data.rating
	n_favorite.set_pressed_no_signal(game_data.favorite)
	n_developer.text = n_base_text[n_developer] % game_data.developer
	n_publisher.text = n_base_text[n_publisher] % game_data.publisher
	n_genres.text = n_base_text[n_genres] % game_data.genres[0] if not game_data.genres.is_empty() else "unknown"
	n_release_date.text = n_base_text[n_release_date] % RegionUtils.localize_date(game_data.release_date)

func _on_favorite_toggled(button_pressed):
	game_data.favorite = button_pressed

func grab_focus():
	n_play.grab_focus()

func _on_play_pressed():
	RetroHub.launch_game()
