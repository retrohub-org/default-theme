extends Control

var Utils := preload("res://Utils.gd").new()

@onready var n_name := %Name
@onready var n_logo := %Logo
@onready var n_age_rating := %AgeRating
@onready var n_media_selection := %MediaSelection
@onready var n_box_render := %BoxRender
@onready var n_support_render := %SupportRender

@onready var n_background_blur := %BackgroundBlur
@onready var n_image_preview := %ImagePreview
@onready var n_video_preview := %VideoPreview
@onready var n_video_controls := $VideoControls

@onready var n_game_title := %GameTitle
@onready var n_game_renders := %GameRenders

@onready var media_selection_orig_rect : Rect2 = n_media_selection.get_rect()
@onready var image_preview_orig_rect : Rect2 = n_image_preview.get_rect()

var media_expanded := false

var game_data : RetroHubGameData:
	set(value):
		game_data = value
		populate()

func _ready():
	RetroHubMedia.media_loaded.connect(_on_media_loaded)

func _on_media_loaded(media: RetroHubGameMediaData, data: RetroHubGameData, _types: int):
	if not visible or game_data != data: return
	if media.logo:
		n_logo.texture = media.logo
		n_logo.visible = true
		n_name.visible = false
	if media.box_render:
		n_box_render.texture = media.box_render
	if media.support_render:
		n_support_render.texture = media.support_render

func populate():
	n_name.text = game_data.name

	n_logo.visible = false
	for child in n_age_rating.get_children():
		child.queue_free()

	var age_rating_node := RegionUtils.localize_age_rating(game_data.age_rating)
	n_age_rating.add_child(age_rating_node)

	n_media_selection.populate(game_data)

func animate_enter(time: float):
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)

	tween.tween_property(n_game_title, "modulate:a", 0.0, time)
	tween.tween_property(n_game_renders, "modulate:a", 0.0, time)
	tween.tween_property(n_media_selection, "position:x", n_media_selection.position.x - n_media_selection.size.x, time)

	tween.set_parallel(false)
	tween.tween_property(n_game_title, "visible", false, 0)
	tween.tween_property(n_game_renders, "visible", false, 0)

	if n_image_preview.texture:
		set_image_size(n_image_preview, n_image_preview.texture, time)
	if n_video_preview.get_video_texture() and RetroHub.is_main_app():
		n_background_blur.texture = n_video_preview.get_video_texture()
		set_image_size(n_video_preview, n_video_preview.get_video_texture(), time)

	n_video_controls.visible = n_video_preview.visible
	media_expanded = true

func set_image_size(node: Control, texture: Texture2D, time: float):
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)

	var preview_size : Vector2 = texture.get_size()
	var total_size := Vector2(1152 - n_media_selection.size.x, 648 * 0.8)

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
	# If the calculated width ends up being bigger than the total_size, we need to reduce it
	if desired_size.x > total_size.x:
		desired_size.y = total_size.x * desired_size.y / desired_size.x
		desired_size.x = total_size.x
	
	var desired_pos = Vector2(
		(total_size.x - desired_size.x) / 2.0,
		(total_size.y - desired_size.y) / 2.0
	)

	tween.tween_property(node, "position", desired_pos, time)
	tween.tween_property(node, "size", desired_size, time)
	
	tween.tween_property(n_background_blur, "position", Vector2.ZERO, time)
	tween.tween_property(n_background_blur, "size", total_size, time)

func set_fullscreen_image(time: float):
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)

	tween.tween_property(n_image_preview, "position", image_preview_orig_rect.position, time)
	tween.tween_property(n_image_preview, "size", image_preview_orig_rect.size, time)

func set_fullscreen_video(time: float):
	# This is needed because Godot doesn't offer an expand with aspect ratio covered
	# like for TextureRects. So, we manually calculate the pos and size
	if not n_video_preview.visible or \
		not RetroHub.is_main_app() or \
		not n_video_preview.get_video_texture(): return


	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)

	var preview_size : Vector2 = n_video_preview.get_video_texture().get_size()
	var total_size := Vector2(1152, 648 * 0.4)
	
	var desired_size := Vector2(
		total_size.x,
		total_size.x * preview_size.y / preview_size.x
	)
	var desired_pos := Vector2(
		0,
		(total_size.y - desired_size.y) / 2.0
	)
	tween.tween_property(n_video_preview, "position", desired_pos, time)
	tween.tween_property(n_video_preview, "size", desired_size, time)
	
	# Remove background blur texture. Shouls save some resources
	tween.set_parallel(false).tween_callback(func():
		n_background_blur.texture = null
	)

func animate_exit(time: float):
	# Restore original layout
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)

	tween.tween_property(n_game_title, "visible", true, 0)
	tween.tween_property(n_game_renders, "visible", true, 0)

	tween.tween_property(n_game_title, "modulate:a", 1.0, time)
	tween.tween_property(n_game_renders, "modulate:a", 1.0, time)
	tween.tween_property(n_media_selection, "position:x", media_selection_orig_rect.position.x, time)

	set_fullscreen_image(time)
	set_fullscreen_video(time)

	n_video_controls.visible = false

	media_expanded = false

func free_media():
	n_image_preview.texture = null
	n_background_blur.texture = null
	n_box_render.texture = null
	n_support_render.texture = null
	n_video_preview.stream = null

func make_preview_visible(preview: Node):
	for node in [
		n_image_preview,
		n_video_preview
	]:
		node.visible = node == preview

func _on_media_selection_media_pressed(media: Resource, type: RetroHubMedia.Type):
	match type:
		RetroHubMedia.Type.VIDEO:
			n_video_preview.stream = media
			n_background_blur.texture = n_video_preview.get_video_texture()
			handle_filtering(n_video_preview, game_data.system)
			make_preview_visible(n_video_preview)
			# We can only playback MP4 video on released app
			if RetroHub.is_main_app():
				if media_expanded:
					set_image_size(n_video_preview, n_video_preview.get_video_texture(), 0)
				else:
					set_fullscreen_video(0)
			n_video_controls.visible = media_expanded
			n_video_controls.video_player = n_video_preview
		_:
			n_image_preview.texture = media
			handle_filtering(n_image_preview, game_data.system)
			n_video_preview.stream = null
			n_background_blur.texture = n_image_preview.texture if type == RetroHubMedia.Type.TITLE_SCREEN or type == RetroHubMedia.Type.SCREENSHOT else null
			make_preview_visible(n_image_preview)
			if media_expanded:
				set_image_size(n_image_preview, n_image_preview.texture, 0)
			else:
				set_fullscreen_image(0)
			n_video_controls.visible = false

func handle_filtering(control: Control, system: RetroHubSystemData):
	control.texture_filter = TEXTURE_FILTER_NEAREST if Utils.is_low_res_system(system) else TEXTURE_FILTER_LINEAR

func _on_video_preview_finished():
	n_video_preview.stream_position = 0
	n_video_preview.play()
