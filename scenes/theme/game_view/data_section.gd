extends Control

@onready var n_info_bar := %InfoBar

@onready var n_metadata := %Metadata
@onready var n_no_metadata := %NoMetadata

@onready var n_play := %Play
@onready var n_age_rating := %AgeRating
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

@onready var n_scrape_metadata := %ScrapeMetadata

@onready var n_favorite_checked := %StarFilled
@onready var n_favorite_unchecked := %StarUnfilled

@onready var n_base_text := {
	n_developer: n_developer.text,
	n_publisher: n_publisher.text,
	n_genres: n_genres.text,
	n_release_date: n_release_date.text,
}

var game_data : RetroHubGameData:
	set(value):
		game_data = value
		populate()

func _ready():
	RetroHubConfig.game_data_updated.connect(func(game_data: RetroHubGameData):
		if self.game_data == game_data and is_visible_in_tree():
			self.game_data = game_data
	)

func set_bottom_focus(node_path):
	if n_no_metadata.visible:
		var n_scrape_metadata_path : NodePath = "../../../../" + node_path
		n_scrape_metadata.focus_neighbor_bottom = n_scrape_metadata_path
	else:
		var n_play_node_path : NodePath = "../../../../../../" + node_path
		var n_favorite_node_path : NodePath = "../../../../../" + node_path
		n_play.focus_neighbor_bottom = n_play_node_path
		n_favorite.focus_neighbor_bottom = n_favorite_node_path

func _get_minimum_size():
	if n_info_bar:
		return n_info_bar.size
	return Vector2.ZERO

func populate():
	n_metadata.visible = game_data.has_metadata
	n_no_metadata.visible = not game_data.has_metadata
	for child in n_age_rating.get_children():
		child.queue_free()
	if game_data.has_metadata:
		n_description.text = game_data.description
		n_play_date.text = RegionUtils.localize_date(game_data.last_played) if not game_data.last_played.is_empty() else "never played before"
		n_play_count.text = str(game_data.play_count) if game_data.play_count > 0 else "never played before"
		n_num_players.text = "Single player" if game_data.num_players == "1-1" else "Multi player\n(%s)" % game_data.num_players
		n_rating.value = game_data.rating
		n_favorite_checked.visible = game_data.favorite
		n_favorite_unchecked.visible = not game_data.favorite
		n_developer.text = n_base_text[n_developer] % game_data.developer
		n_publisher.text = n_base_text[n_publisher] % game_data.publisher
		n_genres.text = n_base_text[n_genres] % game_data.genres[0] if not game_data.genres.is_empty() else "unknown"
		n_release_date.text = n_base_text[n_release_date] % RegionUtils.localize_date(game_data.release_date)

		var age_rating_node := RegionUtils.localize_age_rating(game_data.age_rating)
		age_rating_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		age_rating_node.size_flags_vertical = Control.SIZE_EXPAND_FILL
		n_age_rating.add_child(age_rating_node)
	else:
		n_rating.value = 0
		n_num_players.text = "unknown"
		
		var age_rating_node := RegionUtils.localize_age_rating("0/0/0")
		age_rating_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		age_rating_node.size_flags_vertical = Control.SIZE_EXPAND_FILL
		n_age_rating.add_child(age_rating_node)

func _on_favorite_toggled(button_pressed):
	n_favorite_checked.visible = button_pressed
	n_favorite_unchecked.visible = not button_pressed
	game_data.favorite = button_pressed

func grab_focus():
	n_play.grab_focus()

func _on_play_pressed():
	RetroHub.launch_game()


func _on_favorite_pressed():
	game_data.favorite = not game_data.favorite
	n_favorite_checked.visible = game_data.favorite
	n_favorite_unchecked.visible = not game_data.favorite


func _on_focus_entered():
	n_play.grab_focus()


func _on_edit_metadata_pressed():
	RetroHubUI.open_app_config(RetroHubUI.ConfigTabs.GAME)


func _on_scrape_metadata_pressed():
	RetroHubUI.open_app_config(RetroHubUI.ConfigTabs.SCRAPER)
