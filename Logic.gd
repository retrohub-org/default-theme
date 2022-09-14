extends Node

onready var n_no_games := $"%NoGames"

# _ready function, called everytime the theme is loaded, and only once
func _ready():
	RetroHub.connect("game_receive_start", self, "_on_game_receive_start")

func _on_game_receive_start():
	remove_child(n_no_games)
	n_no_games.queue_free()
