extends Button

@onready var n_preview := %Preview
@onready var n_blurhash := %BlurHash
@onready var n_anim := %AnimationPlayer

var media_loaded := false
var hash_loaded := false
var requested_type : RetroHubMedia.Type

var media_failed := false

var game_data : RetroHubGameData:
	set(value):
		game_data = value

		text = game_data.name
		media_loaded = false
		hash_loaded = false

func _ready():
	RetroHubMedia.media_loaded.connect(_on_media_loaded)
	RetroHubConfig.game_data_updated.connect(_on_game_data_updated)

func _exit_tree():
	RetroHubMedia.media_loaded.disconnect(_on_media_loaded)

func _on_game_data_updated(data: RetroHubGameData):
	if self.game_data == data and is_visible_in_tree():
		self.game_data = data

var last_global_y := global_position.y
func _process(_delta):
	if game_data and game_data.has_media and not media_loaded:
		var global_y := global_position.y
		var delta = global_y - last_global_y
		last_global_y = global_y

		check_load_media(global_y, delta)

func check_load_media(y: float, delta: float):
	# Load if we are inside the limits
	if abs(delta) > 10:
		hash_loaded = true
		if not n_blurhash.texture:
			n_blurhash.visible = true
			var media := RetroHubMedia.retrieve_media_blurhash(game_data, RetroHubMedia.Type.TITLE_SCREEN)
			n_blurhash.texture = media.title_screen
			n_anim.play("RESET")
	else:
		# Load full media
		media_loaded = true
		requested_type = RetroHubMedia.Type.TITLE_SCREEN
		var media := RetroHubMedia.retrieve_media_data_and_blurhash_async(game_data, requested_type)
		n_blurhash.texture = media.title_screen

func _on_media_loaded(media: RetroHubGameMediaData, data: RetroHubGameData, types: int):
	# Do we match game data?
	if self.game_data != data: return
	# Do we already have a texture set?
	if n_preview.texture: return
	# Has media been unloaded meanwhile?
	if media_loaded == false: return
	# If this wasn't the requested type, we are catching a request from some other node
	if requested_type != types: return

	if types == RetroHubMedia.Type.TITLE_SCREEN:
		if media.title_screen:
			n_preview.texture = media.title_screen
			n_anim.play("fade_preview")
		else:
			requested_type = RetroHubMedia.Type.SCREENSHOT
			var preview := RetroHubMedia.retrieve_media_data_and_blurhash_async(game_data, requested_type)
			n_blurhash.texture = preview.screenshot
	elif types == RetroHubMedia.Type.SCREENSHOT:
		if media.screenshot:
			n_preview.texture = media.screenshot
			n_anim.play("fade_preview")
		else:
			requested_type = RetroHubMedia.Type.LOGO
			var preview := RetroHubMedia.retrieve_media_data_and_blurhash_async(game_data, requested_type)
			n_blurhash.texture = preview.logo
	elif types == RetroHubMedia.Type.LOGO:
		if media.logo:
			n_preview.texture = media.logo
			n_anim.play("fade_preview")
		else:
			requested_type = RetroHubMedia.Type.BOX_RENDER
			var preview := RetroHubMedia.retrieve_media_data_and_blurhash_async(game_data, requested_type)
			n_blurhash.texture = preview.box_render
	elif types == RetroHubMedia.Type.BOX_RENDER:
		if media.box_render:
			n_preview.texture = media.box_render