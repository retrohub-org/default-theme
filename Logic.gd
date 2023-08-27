extends Control

@onready var n_game_selector := %GameSelector
@onready var n_game_view := %GameView
@onready var n_anim := %Anim

var is_on_game_view := false

func _ready():
	RetroHubConfig.config_updated.connect(_on_config_updated)
	
	OS.low_processor_usage_mode = true

func _on_config_updated(key: String, _old, _new):
	if key == ConfigData.KEY_GAMES_DIR:
		RetroHub.request_theme_reload()

func _on_controller_button_pressed():
	RetroHubUI.open_app_config()


func _on_game_view_preview_ready():
	is_on_game_view = true
	n_anim.play("transition_view")


func _on_game_view_on_back_pressed():
	is_on_game_view = false
	n_anim.play("transition_seletor")
	await n_anim.animation_finished
	if not is_on_game_view:
		n_game_view.free_media()

