extends PopupDialog

onready var n_info_scroll := $"%InfoScrollContainer"
onready var n_media_scroll := $"%MediaScrollContainer"

onready var n_age_rating_cont := $"%AgeRatingContainer"
onready var n_name := $"%Name"
onready var n_description := $"%Description"
onready var n_developer := $"%Developer"
onready var n_publisher := $"%Publisher"
onready var n_release_date := $"%ReleaseDate"
onready var n_rating := $"%Rating"
onready var n_genres := $"%Genres"
onready var n_num_players := $"%NumPlayers"
onready var n_favorite := $"%Favorite"
onready var n_play_count := $"%PlayCount"

onready var n_no_media := $"%NoMedia"
onready var n_texture_root := $"%TextureRoot"
onready var n_video_controls := $"%VideoControls"
onready var n_media_texture := $"%MediaTexture"
onready var n_media_label := $"%MediaLabel"
onready var n_media_preview_cont := $"%MediaPreviewContainer"

var game_data : RetroHubGameData
var n_age_rating : Control = null
var last_focused : Control = null

var scroll_vertical : float = 0
var scroll_horizontal : float = 0
export(float) var scroll_speed : float = 500

var media_types : int = RetroHubMedia.Type.SCREENSHOT | \
	RetroHubMedia.Type.TITLE_SCREEN | RetroHubMedia.Type.LOGO | \
	RetroHubMedia.Type.BOX_RENDER | RetroHubMedia.Type.SUPPORT_RENDER | \
	RetroHubMedia.Type.VIDEO

func _on_show_game_info(data: RetroHubGameData):
	game_data = data
	last_focused = get_focus_owner()
	RetroHub.set_curr_game_data(data)
	show_game_data()
	show_game_media()
	popup_centered()

func _ready():
	RetroHubConfig.connect("game_data_updated", self, "_on_game_data_updated")

func _on_game_data_updated(data: RetroHubGameData):
	if game_data == data:
		show_game_data()

func _unhandled_input(event):
	if visible:
		get_tree().set_input_as_handled()
		if event.is_action("rh_back") or event.is_action_pressed("rh_major_option"):
			hide()
		if event.is_action("rh_rstick_up") or event.is_action("rh_rstick_down"):
			scroll_vertical = Input.get_axis("rh_rstick_up", "rh_rstick_down")
		if event.is_action("rh_rstick_left") or event.is_action("rh_rstick_right"):
			scroll_horizontal = Input.get_axis("rh_rstick_left", "rh_rstick_right")

func _process(delta):
	n_info_scroll.scroll_vertical += scroll_vertical * delta * scroll_speed
	n_media_scroll.scroll_horizontal += scroll_horizontal * delta * scroll_speed

func show_game_data():
	n_name.text = game_data.path.get_file() if game_data.name.empty() else game_data.name
	handle_age_rating()
	n_description.text = "(no description)" if game_data.description.empty() else game_data.description
	n_developer.text = "Unknown" if game_data.developer.empty() else game_data.developer
	n_publisher.text = "Unknown" if game_data.publisher.empty() else game_data.publisher
	n_release_date.text = "Unknown" if game_data.release_date.empty() else RegionUtils.localize_date(game_data.release_date)
	n_rating.text = str(int(stepify(game_data.rating, 0.01) * 100)) + "%"
	n_genres.text = "Unknown" if game_data.genres.empty() else game_data.genres[0]
	n_num_players.text = "Unknown" if game_data.num_players.empty() else handle_num_players()
	n_favorite.pressed = game_data.favorite
	n_play_count.text = handle_play_count()

func handle_age_rating():
	if n_age_rating:
		n_age_rating_cont.remove_child(n_age_rating)
		n_age_rating.free()
	n_age_rating = RegionUtils.localize_age_rating(game_data.age_rating)
	n_age_rating_cont.add_child(n_age_rating)

func handle_num_players() -> String:
	var splits := game_data.num_players.split("-")
	if splits.empty():
		return "Unknown"
	elif splits.size() < 2:
		return str(splits[0])
	elif splits[0] == splits[1]:
		return str(splits[0])
	else:
		return str(splits[0]) + " - " + str(splits[1])

func handle_play_count() -> String:
	var result := str(game_data.play_count)
	var last_played := game_data.last_played
	if last_played.empty() or last_played == "null":
		result += " (never played)"
	else:
		result += " (last played at " + RegionUtils.localize_date(last_played) + ")"
	return result

func show_game_media():
	for child in n_media_preview_cont.get_children():
		n_media_preview_cont.remove_child(child)
		child.free()
	var media := RetroHubMedia.retrieve_media_data(game_data, media_types)
	if not media:
		n_no_media.visible = true
		n_texture_root.visible = false
		n_video_controls.visible = false
		return
	
	# Video first
	if media.video:
		var preview = preload("res://scenes/media/VideoPreview.tscn").instance()
		n_media_preview_cont.add_child(preview)
		preview.video = media.video
		preview.connect("pressed", self, "_on_video_preview_pressed", [preview])

	# Then images
	var images := [
		[media.screenshot, "Screenshot"],
		[media.title_screen, "Title Screen"],
		[media.logo, "Logo"],
		[media.box_render, "Game Box"],
		[media.support_render, "Game Support"]
	]
	for image in images:
		var tex = image[0]
		var type = image[1]
		if tex:
			var preview = preload("res://scenes/media/MediaPreview.tscn").instance()
			n_media_preview_cont.add_child(preview)
			preview.texture = tex
			preview.type = type
			preview.connect("pressed", self, "_on_media_preview_pressed", [preview])
	
	# Check which first media to show
	n_no_media.visible = not n_media_preview_cont.get_child_count()
	if n_media_preview_cont.get_child_count():
		var child = n_media_preview_cont.get_child(0)
		yield(get_tree(), "idle_frame")
		child.grab_focus()
		if media.video:
			_on_video_preview_pressed(child)
		else:
			_on_media_preview_pressed(child)
	else:
		n_texture_root.visible = false
		n_video_controls.visible = false

func _on_media_preview_pressed(preview: Control):
	n_texture_root.visible = true
	n_video_controls.visible = false
	n_video_controls.stop()
	n_media_label.text = preview.type
	n_media_texture.texture = preview.texture

func _on_video_preview_pressed(preview: Control):
	n_texture_root.visible = false
	n_video_controls.visible = true
	n_video_controls.set_video(preview.video)
	n_video_controls.play()


func _on_GameInfo_popup_hide():
	n_video_controls.stop()
	if is_instance_valid(last_focused):
		last_focused.grab_focus()


func _on_PlayButton_pressed():
	RetroHub.launch_game()
