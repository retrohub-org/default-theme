extends Control

signal calculate_label_positions(node)

@export var system_games_container : PackedScene

@onready var n_root := $".."
@onready var n_container := %Container
@onready var n_recent_games := %RecentGames
@onready var n_favorite_games := %FavoriteGames
@onready var n_library_label := %LibraryLabel
@onready var n_no_games_label := %NoGamesLabel


var n_system_nodes := {}

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.system_receive_start.connect(func():
		n_container.remove_child(n_no_games_label)
		n_no_games_label.queue_free()
	)
	RetroHub.system_received.connect(_on_system_received)
	RetroHub.game_receive_end.connect(_on_game_receive_end)

func _get_prev_container(idx: int):
	for i in range(idx-1, -1, -1):
		var child = n_container.get_child(i)
		if child == n_library_label: continue
		if not child.visible: continue
		return child
	return null

func _get_next_container(idx: int):
	for i in range(idx+1, n_container.get_child_count()):
		var child = n_container.get_child(i)
		if child == n_library_label: continue
		if not child.visible: continue
		return child
	return null

func _on_system_received(data: RetroHubSystemData):
	var scene = system_games_container.instantiate()
	n_container.add_child(scene)
	scene.system_data = data
	n_system_nodes[data] = scene

func _calculate_positions():
	for i in range(n_container.get_child_count()):
		var node = n_container.get_child(i)
		if node == n_library_label: continue

		node.prev_container = _get_prev_container(i)
		node.next_container = _get_next_container(i)

	# Emit signal for computing system label positions
	calculate_label_positions.emit(self)

func _on_game_receive_end():
	await get_tree().process_frame
	_calculate_positions()
	# Connect next/prev systems to fixed containers
	n_recent_games.next_container = n_favorite_games
	n_favorite_games.prev_container = n_recent_games
	
	# Focus the first object
	if n_recent_games.grab_first_focus(): return
	if n_favorite_games.grab_first_focus(): return
	for system in n_container.get_children():
		if system.grab_first_focus(): return

func search(search_term: String):
	n_recent_games.search_requested(search_term)
	n_favorite_games.search_requested(search_term)
	for node in n_system_nodes.values():
		node.search_requested(search_term)
	_calculate_positions()

func search_add(search_term: String):
	n_recent_games.search_add_requested(search_term)
	n_favorite_games.search_add_requested(search_term)
	for node in n_system_nodes.values():
		node.search_add_requested(search_term)
	_calculate_positions()

func search_sub(search_term: String):
	n_recent_games.search_sub_requested(search_term)
	n_favorite_games.search_sub_requested(search_term)
	for node in n_system_nodes.values():
		node.search_sub_requested(search_term)
	_calculate_positions()
