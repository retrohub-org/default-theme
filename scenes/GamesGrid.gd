extends HFlowContainer

signal show_game_info(game_data)

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.connect("game_received", self, "_on_game_received")

func _on_game_received(data: RetroHubGameData):
	var button
	if data.has_media:
		button = preload("res://scenes/game_box/GameBoxImage.tscn").instance()
	else:
		button = preload("res://scenes/game_box/GameBoxSimple.tscn").instance()
	add_child(button)
	button.game_data = data
	button.connect("show_game_info", self, "_on_show_game_info")

func _on_show_game_info(data: RetroHubGameData):
	emit_signal("show_game_info", data)


func _on_SystemBar_system_selected(data: RetroHubSystemData, should_focus: bool):
	var selected = false
	for child in get_children():
		child.visible = child.game_data.system == data
		if should_focus and child.visible and not selected:
			child.grab_focus()
			selected = true
