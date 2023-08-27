extends Button

signal game_preview_selected(data: RetroHubGameData, select_on_ui: bool)
signal game_pressed(data: RetroHubGameData)

@onready var n_preview := %Preview
@onready var n_blurhash := %BlurHash
@onready var n_anim := %AnimationPlayer

@onready var min_y = -50
@onready var max_y = 648 + 50

var media_loaded := false
var hash_loaded := false

var game_data : RetroHubGameData:
	set(value):
		game_data = value

		if not game_data.has_media:
			text = game_data.name

func _ready():
	RetroHubMedia.media_loaded.connect(_on_media_loaded)

var last_global_y := global_position.y
func _process(_delta):
	if game_data.has_media:
		var global_y := global_position.y
		var delta = global_y - last_global_y
		last_global_y = global_y

		# Handle behavior differently if currently loaded media or not
		if not media_loaded:
			check_load_media(global_y, delta)
		if media_loaded or hash_loaded:
			check_unload_media(global_y, delta)

# Check if we should unload media
func check_unload_media(y: float, delta: float):
	# Unload if we leave the limits
	if y + size.y < min_y or y > max_y:
		media_loaded = false
		hash_loaded = false
		n_preview.texture = null
		n_blurhash.texture = null

func check_load_media(y: float, delta: float):
	# Load if we are inside the limits
	if y + size.y >= min_y and y <= max_y:
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
			var media := RetroHubMedia.retrieve_media_data_and_blurhash_async(game_data, RetroHubMedia.Type.TITLE_SCREEN)
			n_blurhash.texture = media.title_screen

func _on_media_loaded(media: RetroHubGameMediaData, data: RetroHubGameData, types: int):
	# Do we match game data?
	if self.game_data != data: return
	# Do we already have a texture set?
	if n_preview.texture: return
	# Has media been unloaded meanwhile?
	if media_loaded == false: return

	if types == RetroHubMedia.Type.TITLE_SCREEN:
		if media.title_screen:
			n_preview.texture = media.title_screen
			n_anim.play("fade_preview")
		else:
			var preview := RetroHubMedia.retrieve_media_data_and_blurhash_async(game_data, RetroHubMedia.Type.SCREENSHOT)
			n_blurhash.texture = preview.screenshot
	elif types == RetroHubMedia.Type.SCREENSHOT:
		if media.screenshot:
			n_preview.texture = media.screenshot
			n_anim.play("fade_preview")
		else:
			var preview := RetroHubMedia.retrieve_media_data_and_blurhash_async(game_data, RetroHubMedia.Type.LOGO)
			n_blurhash.texture = preview.logo
	elif types == RetroHubMedia.Type.LOGO:
		if media.logo:
			n_preview.texture = media.logo
			n_anim.play("fade_preview")
		else:
			var preview := RetroHubMedia.retrieve_media_data_and_blurhash_async(game_data, RetroHubMedia.Type.BOX_RENDER)
			n_blurhash.texture = preview.box_render
	elif types == RetroHubMedia.Type.BOX_RENDER:
		if media.box_render:
			n_preview.texture = media.box_render
		else:
			text = game_data.name

func _on_mouse_entered():
	game_preview_selected.emit(game_data, false)
	get_tree().call_group("global_signal(on_game_preview_selected)", "_on_game_preview_selected", game_data, false)


func _on_focus_entered():
	game_preview_selected.emit(game_data, true)
	get_tree().call_group("global_signal(on_game_preview_selected)", "_on_game_preview_selected", game_data, true)


func _on_pressed():
	game_pressed.emit(game_data)
	get_tree().call_group("global_signal(on_game_pressed)", "_on_game_pressed", game_data)
