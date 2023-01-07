extends Control

signal show_game_info(game_data)

onready var n_grid := $"%Grid"
onready var n_no_games := $"%NoGamesLabel"

var system_data : RetroHubSystemData

var _sort_method : int = -1

static func sort_alphabetically(a: Node, b: Node):
	var a_data : RetroHubGameData = a.game_data
	var b_data : RetroHubGameData = b.game_data
	if RetroHubConfig.get_theme_config("sort_reversed", false):
		return a_data.name.naturalnocasecmp_to(b_data.name) == -1
	return b_data.name.naturalnocasecmp_to(a_data.name) == -1

static func sort_playdate(a: Node, b: Node):
	var a_data : RetroHubGameData = a.game_data
	var b_data : RetroHubGameData = b.game_data
	var a_date := 0 if a_data.last_played == "null" else \
		int(a_data.last_played.substr(0, 8) + a_data.last_played.substr(10))
	var b_date := 0 if b_data.last_played == "null" else \
		int(b_data.last_played.substr(0, 8) + b_data.last_played.substr(10))
	if RetroHubConfig.get_theme_config("sort_reversed", false):
		return a_date > b_date
	return b_date > a_date

static func sort_playcount(a: Node, b: Node):
	var a_data : RetroHubGameData = a.game_data
	var b_data : RetroHubGameData = b.game_data
	if RetroHubConfig.get_theme_config("sort_reversed", false):
		return a_data.play_count > b_data.play_count
	return b_data.play_count > a_data.play_count

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.connect("game_received", self, "_on_game_received")

func _on_game_received(data: RetroHubGameData):
	if data.system != system_data:
		return

	var button
	if data.has_media:
		button = preload("res://scenes/game_box/GameBoxImage.tscn").instance()
	else:
		button = preload("res://scenes/game_box/GameBoxSimple.tscn").instance()
	n_grid.add_child(button)
	button.game_data = data
	button.connect("show_game_info", self, "_on_show_game_info")

func _on_show_game_info(data: RetroHubGameData):
	emit_signal("show_game_info", data)

func sort_children(sort_method: int, force_sort: bool):
	# Sorting is costly, only do it if there's a change
	if !force_sort and _sort_method == sort_method:
		return

	_sort_method = sort_method
	# Copy existing children and remove them from the node
	var children := n_grid.get_children()
	# Now sort children array
	match _sort_method:
		1: # By Last Played
			children.sort_custom(self, "sort_playdate")
		2: # By Play Count
			children.sort_custom(self, "sort_playcount")
		0, _: # Alphabetically or unknown
			children.sort_custom(self, "sort_alphabetically")
	# Finally, read them to the node
	var idx = 0
	for child in children:
		n_grid.move_child(child, 0)
		idx += 1

func filter_children(filter_method: int):
	var any_visible := false
	for child in n_grid.get_children():
		match filter_method:
			1: # Only favorites
				child.visible = child.game_data.favorite
			2: # Only played before
				child.visible = child.game_data.play_count > 0
			3: # Only with media
				child.visible = child.game_data.has_media
			0: # All, or unknown
				child.visible = true
		any_visible = any_visible or child.visible
	n_no_games.set_visible(!any_visible)

func set_preview_mode(preview_mode: int):
	for child in n_grid.get_children():
		child.set_preview_mode(preview_mode)

func system_selected(should_focus: bool):
	filter_children(RetroHubConfig.get_theme_config("filter_mode", 0))
	sort_children(RetroHubConfig.get_theme_config("sort_mode", 0), true)
	var selected = false
	for child in n_grid.get_children():
		if not selected and should_focus and child.visible:
			child.grab_focus()
			selected = true
