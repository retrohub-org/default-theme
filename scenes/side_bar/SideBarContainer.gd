extends VBoxContainer

@onready var n_games_container := %GamesContainer
@onready var n_side_bar_container := %SideBarContainer
@onready var n_recent_games := %RecentGames
@onready var n_favorite_games := %FavoriteGames
@onready var n_library_games := %LibraryGames

var system_buttons := {}

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.system_received.connect(_on_system_received)


func _on_system_received(data: RetroHubSystemData):
	var btn := Button.new()
	btn.text = data.name
	btn.clip_text = true
	btn.mouse_filter = Control.MOUSE_FILTER_PASS
	n_side_bar_container.add_child(btn)
	system_buttons[data] = btn

func _on_logic_calculate_label_positions(node):
	# Meta buttons
	bind_button_to_offset(n_recent_games, -node.n_recent_games.position.y)
	bind_button_to_offset(n_favorite_games, -node.n_favorite_games.position.y)
	bind_button_to_offset(n_library_games, -node.n_library_label.position.y)

	# System buttons
	var system_nodes : Dictionary = node.n_system_nodes
	for system in system_buttons.keys():
		var btn : Button = system_buttons[system]
		var system_container = system_nodes[system]
		bind_button_to_offset(btn, -system_container.position.y)

func bind_button_to_offset(btn: Button, offset: int):
	if btn.pressed.is_connected(_on_btn_pressed):
		btn.pressed.disconnect(_on_btn_pressed)
	btn.pressed.connect(_on_btn_pressed.bind(offset))
	if btn.focus_entered.is_connected(_on_btn_pressed):
		btn.focus_entered.disconnect(_on_btn_pressed)
	btn.focus_entered.connect(_on_btn_pressed.bind(offset))

func _on_btn_pressed(offset: int):
	var delta = abs(%GamesContainer.pos.y - offset)
	# Depending on delta, we make the scrolling take longer, for a better effect
	# on bigger libraries. 1500px per second, clamped to [0.5, 1.5] seconds
	var time = clamp(delta / 1500.0, 0.5, 1.5)
	%GamesContainer.scroll_y_to(offset, time)
