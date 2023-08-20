extends VBoxContainer

@export var game_preview : PackedScene

@onready var n_container := %Container

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.game_received.connect(_on_game_received)

func _on_game_received(data: RetroHubGameData):
	if data.favorite:
		var preview = game_preview.instantiate()
		n_container.add_child(preview)
		preview.game_data = data
