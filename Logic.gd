extends Node


func _ready():
	RetroHubConfig.config_updated.connect(_on_config_updated)

func _on_config_updated(key: String, _old, _new):
	if key == ConfigData.KEY_GAMES_DIR:
		RetroHub.request_theme_reload()

func _on_controller_button_pressed():
	RetroHubUI.open_app_config()


func _on_game_pressed(data: RetroHubGameData):
	RetroHub.set_curr_game_data(data)
	RetroHub.launch_game()
