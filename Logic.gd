extends Control

@onready var n_game_selector := %GameSelector
@onready var n_game_view := %GameView

func _ready():
	RetroHubConfig.config_updated.connect(_on_config_updated)

func _on_config_updated(key: String, _old, _new):
	if key == ConfigData.KEY_GAMES_DIR:
		RetroHub.request_theme_reload()

func _on_controller_button_pressed():
	RetroHubUI.open_app_config()


func _on_game_preview_visibility_changed():
	n_game_selector.visible = not n_game_view.visible
