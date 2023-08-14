extends Button
class_name GamePreviewButton

signal game_preview_selected(data: RetroHubGameData, select_on_ui: bool)
signal game_pressed(data: RetroHubGameData)

var game_data : RetroHubGameData:
	set(value):
		game_data = value

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
