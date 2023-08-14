extends Node


func _ready():
	RetroHubConfig.config_updated.connect(_on_config_updated)

func _on_config_updated(key: String, _old, _new):
	if key == ConfigData.KEY_GAMES_DIR:
		RetroHub.request_theme_reload()
