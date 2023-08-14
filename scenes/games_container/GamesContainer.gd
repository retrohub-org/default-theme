extends Control

@export var system_games_container : PackedScene

@onready var n_root := $".."
@onready var n_container := %Container

var n_system_nodes := []

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.system_received.connect(_on_system_received)


func _on_system_received(data: RetroHubSystemData):
	var scene : SystemGamesContainer = system_games_container.instantiate()
	n_container.add_child(scene)
	scene.system_data = data
	n_system_nodes.push_back(scene)
