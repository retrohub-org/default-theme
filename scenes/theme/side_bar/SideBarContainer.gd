extends VBoxContainer

@export var system_button : PackedScene

@onready var n_games_container := %GamesContainer
@onready var n_side_bar := %SideBar
@onready var n_side_bar_container := %SideBarContainer
@onready var n_recent_games := %RecentGames
@onready var n_favorite_games := %FavoriteGames
@onready var n_library := %Library

var system_buttons := {}

var group := ButtonGroup.new()

var scroll_offsets := []

var scroll_limit_idx := -1
var scroll_limit_up := -1
var scroll_limit_down := -1

var focus_on := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.system_received.connect(_on_system_received)
	n_recent_games.button_group = group
	n_favorite_games.button_group = group
	n_library.button_group = group

func _on_system_button_focus_entered(button: Button):
	focus_on += 1
	button.button_pressed = true

func _on_system_button_focus_exited():
	focus_on = max(focus_on - 1, 0)

func _on_system_received(data: RetroHubSystemData):
	var btn := system_button.instantiate()
	var logo_path := "res://assets/theme/system_icons/%s.png" % data.name
	if ResourceLoader.exists(logo_path):
		btn.icon = load(logo_path)
		btn.text = " "
	else:
		btn.text = data.name
	btn.button_group = group
	n_side_bar_container.add_child(btn)
	system_buttons[data] = btn

func _handle_signal_connections(node: Control):
	for data in [
		["focus_entered", _on_system_button_focus_entered.bind(node)],
		["focus_exited", _on_system_button_focus_exited]
	]:
		if node.is_connected(data[0], data[1]):
			node.disconnect(data[0], data[1])
		node.connect(data[0], data[1])

func _on_logic_calculate_label_positions(node):
	# Meta buttons
	await get_tree().process_frame
	scroll_offsets.clear()
	for data in [
		[n_recent_games, node.n_recent_games],
		[n_favorite_games, node.n_favorite_games],
		[n_library, node.n_library_label]
	]:
		var btn_node : Control = data[0]
		var offset_node : Control = data[1]
		bind_button_to_offset(btn_node, offset_node)
		_handle_signal_connections(btn_node)

	# System buttons
	var system_nodes : Dictionary = node.n_system_nodes
	for system in system_buttons.keys():
		var btn : Button = system_buttons[system]
		var system_container = system_nodes[system]
		bind_button_to_offset(btn, system_container)
		_handle_signal_connections(btn)

	compute_scroll_limits()

func compute_scroll_limits():
	for idx in range(1,scroll_offsets.size()-1):
		if scroll_offsets[idx][0] > n_games_container.scroll_vertical:
			scroll_limit_idx = idx-1
			scroll_limit_up = scroll_offsets[scroll_limit_idx][0]
			scroll_limit_down = scroll_offsets[scroll_limit_idx+1][0]
			focus_system_button()
			return

func focus_system_button():
	var btn : Button = scroll_offsets[scroll_limit_idx][1]
	if focus_on > 0: return
	btn.button_pressed = true
	n_side_bar.scroll_y_to(-btn.position.y)

func bind_button_to_offset(btn: Button, node: Control):
	if not node.visible:
		btn.visible = false
		return
	btn.visible = true
	var pos := -node.position.y
	scroll_offsets.push_back([-pos, btn])
	for sig in ["pressed", "focus_entered"]:
		if btn.is_connected(sig, _on_btn_pressed):
			btn.disconnect(sig, _on_btn_pressed)
		btn.connect(sig, _on_btn_pressed.bind(pos))

func _on_btn_pressed(offset: int):
	var delta = abs(%GamesContainer.pos.y - offset)
	# Depending on delta, we make the scrolling take longer, for a better effect
	# on bigger libraries. 1500px per second, clamped to [0.5, 1.5] seconds
	var time = clamp(delta / 1500.0, 0.5, 1.5)
	%GamesContainer.scroll_y_to(offset, time)


func _on_games_container_scroll_vertical_tick(value):
	# Add 1 due to precision errors (e.g. 2443.47729492188 < 2444)
	value += 1
	if value >= scroll_limit_down:
		scroll_limit_idx += 1
		scroll_limit_up = scroll_offsets[scroll_limit_idx][0]
		scroll_limit_down = scroll_offsets[scroll_limit_idx+1][0]
		focus_system_button()
	elif value < scroll_limit_up and value > 0:
		scroll_limit_idx -= 1
		scroll_limit_up = scroll_offsets[scroll_limit_idx][0]
		scroll_limit_down = scroll_offsets[scroll_limit_idx+1][0]
		focus_system_button()


func _on_focus_entered():
	# Focus the currently selected button
	if n_recent_games.button_pressed:
		n_recent_games.grab_focus()
		return
	if n_favorite_games.button_pressed:
		n_favorite_games.grab_focus()
		return
	if n_library.button_pressed:
		n_library.grab_focus()
		return
	for btn in n_side_bar_container.get_children():
		if btn.button_pressed:
			btn.grab_focus()
			return


func _on_side_bar_mouse_exited():
	focus_on = 0
