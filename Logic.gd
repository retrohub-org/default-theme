extends Control

@onready var n_game_selector := %GameSelector
@onready var n_game_view := %GameView
@onready var n_anim := %Anim

@onready var n_search_bar := %SearchBar
@onready var n_games_container := %GamesContainer

var is_on_game_view := false

var last_preview : Control

func _on_game_pressed(data: RetroHubGameData, preview: Control):
	last_preview = preview

func _ready():
	RetroHubConfig.config_updated.connect(_on_config_updated)

	OS.low_processor_usage_mode = true

func _process(delta):
	n_search_bar.set_focus_mode(FOCUS_ALL if n_games_container.scroll_vertical < 100 else FOCUS_NONE)

func _on_config_updated(key: String, _old, _new):
	if key == ConfigData.KEY_GAMES_DIR:
		RetroHub.request_theme_reload()

func _on_controller_button_pressed():
	RetroHubUI.open_app_config()


func _on_game_view_preview_ready():
	if is_on_game_view: return
	if n_anim.is_playing():
		await n_anim.animation_finished
	is_on_game_view = true
	n_anim.play("transition_view")

func _on_game_view_on_back_pressed():
	if not is_on_game_view: return
	if n_anim.is_playing():
		await n_anim.animation_finished
	is_on_game_view = false
	n_anim.play("transition_seletor")
	if last_preview:
		print("Grabbing focus")
		last_preview.grab_focus()
	await n_anim.animation_finished
	if not is_on_game_view:
		n_game_view.free_media()
