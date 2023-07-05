extends Control

signal show_game_info(game_data)
signal game_selected(game_data)
signal expensive_sort()
signal sort_over()

@onready var n_grid := %Grid
@onready var n_no_games := %NoGamesLabel

var system_data : RetroHubSystemData

var _sort_method : int = -1
var _filter_method : int = -1

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
	RetroHub.game_received.connect(_on_game_received)

func _on_game_received(data: RetroHubGameData):
	if data.system != system_data:
		return

	var button = preload("res://scenes/game_box/GameBox.tscn").instantiate()
	n_grid.add_child(button)
	button.game_data = data
	button.show_game_info.connect(_on_show_game_info)
	button.game_selected.connect(_on_game_selected)

func _on_show_game_info(data: RetroHubGameData):
	emit_signal("show_game_info", data)

func _on_game_selected(data: RetroHubGameData):
	emit_signal("game_selected", data)

func sort_children(sort_method: int, force_sort: bool):
	# Sorting is costly, only do it if there's a change
	if !force_sort and _sort_method == sort_method:
		return
	
	_sort_method = sort_method
	# Copy existing children and remove them from the node
	var children := n_grid.get_children()
	# If there's a lot of children, show a warning label
	if children.size() >= 50:
		emit_signal("expensive_sort")
		await get_tree().process_frame
		await get_tree().process_frame

	# Now sort children array
	match _sort_method:
		1: # By Last Played
			children.sort_custom(Callable(self, "sort_playdate"))
		2: # By Play Count
			children.sort_custom(Callable(self, "sort_playcount"))
		0, _: # Alphabetically or unknown
			children.sort_custom(Callable(self, "sort_alphabetically"))
	# Finally, read them to the node
	var idx = 0
	for child in children:
		n_grid.move_child(child, 0)
		idx += 1
	emit_signal("sort_over")

func filter_children(filter_method: int, force_filter: bool):
	# Filtering is costly, only do it if there's a change
	if !force_filter and _filter_method == filter_method:
		return
	
	_filter_method = filter_method
	# If there's a lot of children, show a warning label
	if n_grid.get_children().size() >= 50:
		emit_signal("expensive_sort")
		await get_tree().process_frame
		await get_tree().process_frame

	var any_visible := false
	for child in n_grid.get_children():
		match _filter_method:
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
	emit_signal("sort_over")

func set_preview_mode(preview_mode: int):
	for child in n_grid.get_children():
		child.set_preview_mode(preview_mode)

func system_selected(should_focus: bool):
	filter_children(RetroHubConfig.get_theme_config("filter_mode", 0), false)
	sort_children(RetroHubConfig.get_theme_config("sort_mode", 0), false)
	var selected = false
	for child in n_grid.get_children():
		if not selected and should_focus and child.visible:
			child.grab_focus()
			selected = true
			await get_tree().process_frame
			TTS.speak("Selected game: " + child.tts_text(null), false)
