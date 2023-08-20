extends Control

signal calculate_label_positions(node)

@export var system_games_container : PackedScene

@onready var n_root := $".."
@onready var n_container := %Container
@onready var n_recent_games := %RecentGames
@onready var n_favorite_games := %FavoriteGames
@onready var n_library_label = %LibraryLabel

var n_system_nodes := {}

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.system_received.connect(_on_system_received)
	RetroHub.system_receive_end.connect(_on_system_receive_end)


func _on_system_received(data: RetroHubSystemData):
	var scene = system_games_container.instantiate()
	n_container.add_child(scene)
	scene.system_data = data
	n_system_nodes[data] = scene

func _on_system_receive_end():
	# Wait a frame for the scroll container to position it's children
	await get_tree().process_frame
	calculate_label_positions.emit(self)
