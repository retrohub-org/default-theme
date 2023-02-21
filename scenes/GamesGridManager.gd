extends Control

signal show_game_info(game_data)
signal game_selected(game_data)

export(PackedScene) var games_grid: PackedScene
var curr_grid : Control = null

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.connect("system_received", self, "_on_system_received")

func _on_system_received(data: RetroHubSystemData):
	var grid : Control = games_grid.instance()
	grid.system_data = data
	grid.connect("show_game_info", self, "_on_show_game_info")
	grid.connect("game_selected", self, "_on_game_selected")
	add_child(grid)

func _on_show_game_info(data: RetroHubGameData):
	emit_signal("show_game_info", data)

func _on_game_selected(data: RetroHubGameData):
	emit_signal("game_selected", data)

func _on_SystemBar_system_selected(data: RetroHubSystemData, should_focus: bool):
	for child in get_children():
		if child.system_data == data:
			child.visible = true
			child.system_selected(should_focus)
			curr_grid = child
		else:
			child.visible = false

func _on_SortFilterPopup_setting_changed(key, value):
	match key:
		"sort_mode", "sort_reversed":
			var mode = value if key == "sort_mode" else RetroHubConfig.get_theme_config("sort_mode", 0)
			curr_grid.sort_children(mode, key == "sort_reversed")
		"filter_mode":
			curr_grid.filter_children(value)
		"preview_mode":
			curr_grid.set_preview_mode(value)
