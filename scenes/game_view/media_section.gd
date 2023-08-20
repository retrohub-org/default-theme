extends Control

var Utils := preload("res://Utils.gd").new()

@onready var n_name := %Name
@onready var n_logo := %Logo
@onready var n_age_rating := %AgeRating
@onready var n_image_preview := %ImagePreview
@onready var n_game_title := %GameTitle
@onready var n_game_renders := %GameRenders
@onready var n_media_selection := %MediaSelection
@onready var n_box_render := %BoxRender
@onready var n_support_render := %SupportRender

@onready var media_selection_orig_rect : Rect2 = n_media_selection.get_rect()
@onready var image_preview_orig_rect : Rect2 = n_image_preview.get_rect()

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
	if media.screenshot:
		n_image_preview.texture = media.screenshot
		n_image_preview.texture_filter = TEXTURE_FILTER_NEAREST if Utils.is_low_res_system(game_data.system) else TEXTURE_FILTER_LINEAR
	if media.box_render:
		n_box_render.texture = media.box_render
	if media.support_render:
		n_support_render.texture = media.support_render

func populate():
	n_name.text = game_data.name

	n_logo.visible = false
	n_image_preview.texture = null
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

	if not n_image_preview.texture: return

	set_image_size(time)

func set_image_size(time: float):
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)

	var preview_size : Vector2 = n_image_preview.texture.get_size()
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

	tween.tween_property(n_image_preview, "position", desired_pos, time)
	tween.tween_property(n_image_preview, "size", desired_size, time)

func animate_exit(time: float):
	# Restore original layout
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)

	tween.tween_property(n_game_title, "modulate:a", 1.0, time)
	tween.tween_property(n_game_renders, "modulate:a", 1.0, time)
	tween.tween_property(n_media_selection, "position:x", media_selection_orig_rect.position.x, time)

	tween.tween_property(n_image_preview, "position", image_preview_orig_rect.position, time)
	tween.tween_property(n_image_preview, "size", image_preview_orig_rect.size, time)


func _on_media_selection_media_pressed(media: Resource, type: RetroHubMedia.Type):
	match type:
		RetroHubMedia.Type.VIDEO:
			pass
		_:
			n_image_preview.texture = media
			set_image_size(0)
