extends Panel

signal media_pressed(media: Resource, type: RetroHubMedia.Type)

@export var image_preview : PackedScene
@export var video_preview : PackedScene

@onready var n_container := %Container

var game_data: RetroHubGameData

func _ready():
	RetroHubMedia.media_loaded.connect(_on_media_loaded)

func _on_media_loaded(media: RetroHubGameMediaData, data: RetroHubGameData, types: RetroHubMedia.Type):
	if game_data != data: return
	if types != RetroHubMedia.Type.ALL: return

	var group := ButtonGroup.new()

	if media.video:
		var preview = video_preview.instantiate()
		n_container.add_child(preview)
		preview.create(media.video, RetroHubMedia.Type.VIDEO)
		preview.button_group = group
		preview.media_pressed.connect(func(media, type):
			media_pressed.emit(media, type)
		)

	# Image previews
	var image_previews = [
		[media.title_screen, RetroHubMedia.Type.TITLE_SCREEN],
		[media.screenshot, RetroHubMedia.Type.SCREENSHOT],
		[media.logo, RetroHubMedia.Type.LOGO],
		[media.box_render, RetroHubMedia.Type.BOX_RENDER],
		[media.support_render, RetroHubMedia.Type.SUPPORT_RENDER]
	]

	for info in image_previews:
		if not info[0]: continue
		var preview = image_preview.instantiate()
		n_container.add_child(preview)
		preview.create(info[0], info[1])
		preview.button_group = group
		preview.media_pressed.connect(func(media, type):
			media_pressed.emit(media, type)
		)
	
	if n_container.get_child_count() > 0:
		n_container.get_child(0).button_pressed = true

func grab_focus():
	for child in n_container.get_children():
		if child.button_pressed:
			child.grab_focus()
			return

func populate(data: RetroHubGameData):
	game_data = data

	for child in n_container.get_children():
		child.queue_free()
		n_container.remove_child(child)

	if data.has_media:
		RetroHubMedia.retrieve_media_data_async(data)


func _on_focus_entered():
	self.grab_focus()
