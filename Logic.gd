extends Node

onready var n_no_games := $"%NoGames"
onready var n_bottom_info := $"%BottomInfo"

# _ready function, called everytime the theme is loaded, and only once
func _ready():
	n_bottom_info.visible = false
	RetroHub.connect("game_receive_start", self, "_on_game_receive_start")

func _on_game_receive_start():
	remove_child(n_no_games)
	n_no_games.queue_free()
	n_bottom_info.visible = true
