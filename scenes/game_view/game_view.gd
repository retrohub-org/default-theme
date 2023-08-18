extends Control

var Utils := preload("res://Utils.gd").new()

var data : RetroHubGameData

@onready var n_name := %Name
@onready var n_logo := %Logo
@onready var n_age_rating := %AgeRating
@onready var n_image_preview := %ImagePreview
@onready var n_game_title := %GameTitle
@onready var n_media_bar := %MediaBar

@onready var n_media_root := %Media
@onready var n_data_root := %Data

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

@onready var media_orig_rect : Rect2 = n_media_root.get_rect()
@onready var data_orig_rect : Rect2 = n_data_root.get_rect()
@onready var media_bar_orig_rect : Rect2 = n_media_bar.get_rect()
@onready var image_preview_orig_rect : Rect2 = n_image_preview.get_rect()

var media_expanded := false

func _ready():
	RetroHubMedia.media_loaded.connect(_on_media_loaded)

func _on_media_loaded(media: RetroHubGameMediaData, data: RetroHubGameData, types: int):
	if not visible or self.data != data: return
	if media.logo:
		n_logo.texture = media.logo
		n_logo.visible = true
		n_name.visible = false
	if media.screenshot:
		n_image_preview.texture = media.screenshot
		n_image_preview.texture_filter = TEXTURE_FILTER_NEAREST if Utils.is_low_res_system(data.system) else TEXTURE_FILTER_LINEAR

func _on_game_pressed(data: RetroHubGameData):
	visible = true
	self.data = data

	_on_data_focus_entered(0.0)

	n_name.text = data.name
	n_description.text = data.description
	n_play_date.text = n_base_text[n_play_date] % (RegionUtils.localize_date(data.last_played) if not data.last_played.is_empty() else "never")
	n_play_count.text = n_base_text[n_play_count] % data.play_count
	n_num_players.text = n_base_text[n_num_players] % data.num_players
	n_rating.value = data.rating
	n_favorite.set_pressed_no_signal(data.favorite)
	n_developer.text = n_base_text[n_developer] % data.developer
	n_publisher.text = n_base_text[n_publisher] % data.publisher
	n_genres.text = n_base_text[n_genres] % data.genres[0] if not data.genres.is_empty() else "unknown"
	n_release_date.text = n_base_text[n_release_date] % RegionUtils.localize_date(data.release_date)

	n_logo.visible = false
	n_image_preview.texture = null
	for child in n_age_rating.get_children():
		child.queue_free()

	var age_rating_node := RegionUtils.localize_age_rating(data.age_rating)
	n_age_rating.add_child(age_rating_node)
	#age_rating_node.set_anchors_preset(Control.PRESET_BOTTOM_LEFT, true)

	if data.has_media:
		RetroHubMedia.retrieve_media_data_async(data, RetroHubMedia.Type.ALL, true)

func _on_back_pressed():
	if media_expanded:
		_on_data_focus_entered()
	else:
		visible = false

func _on_favorite_toggled(button_pressed):
	data.favorite = button_pressed


func _on_media_focus_entered():
	# Give media more by expanding it's size
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)

	tween.tween_property(n_media_root, "size:y", 648 * 0.8, 0.3)
	tween.tween_property(n_data_root, "position:y", 648 * 0.8, 0.3)

	# Re-order media elements
	tween.tween_property(n_game_title, "modulate:a", 0.0, 0.3)
	tween.tween_property(n_media_bar, "position:x", n_media_bar.position.x - n_media_bar.size.x, 0.3)

	if not n_image_preview.texture: return

	var preview_size : Vector2 = n_image_preview.texture.get_size()
	var total_size := Vector2(n_media_bar.position.x - n_media_bar.size.x, 648 * 0.8)

	# Clamp preview size taking into account ratio
	if preview_size.x > total_size.x:
		preview_size.y = total_size.x * preview_size.y / preview_size.x
		preview_size.x = total_size.x
	if preview_size.y > total_size.y:
		preview_size.x = total_size.y * preview_size.x / preview_size.y
		preview_size.y = total_size.y

	# We will match height with total size; find expected width with ratio
	var desired_size = Vector2(
		preview_size.x * total_size.y / preview_size.y,
		total_size.y
	)
	var desired_pos = Vector2(
		(total_size.x - desired_size.x) / 2,
		0.0
	)

	tween.tween_property(n_image_preview, "position", desired_pos, 0.3)
	tween.tween_property(n_image_preview, "size", desired_size, 0.3)

	media_expanded = true

func _on_data_focus_entered(time := 0.3):
	# Restore original layout
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)

	tween.tween_property(n_media_root, "size:y", media_orig_rect.size.y, time)
	tween.tween_property(n_data_root, "position:y", data_orig_rect.position.y, time)

	# Re-order media elements
	tween.tween_property(n_game_title, "modulate:a", 1.0, time)
	tween.tween_property(n_media_bar, "position:x", media_bar_orig_rect.position.x, time)

	tween.tween_property(n_image_preview, "position", image_preview_orig_rect.position, time)
	tween.tween_property(n_image_preview, "size", image_preview_orig_rect.size, time)

	# Make play grab focus
	n_play.grab_focus()

	media_expanded = false

func _on_play_pressed():
	RetroHub.launch_game()
