extends VBoxContainer

@export var game_preview : PackedScene
@export var max_displayed_games := 5

@onready var n_container := %Container

var games : Array[RetroHubGameData] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.game_received.connect(_on_game_received)
	RetroHub.game_receive_end.connect(_on_game_receive_end)

func is_older(a: RetroHubGameData, b: RetroHubGameData):
	var a_date := int(a.last_played.substr(0, 8) + a.last_played.substr(10))
	var b_date := int(b.last_played.substr(0, 8) + b.last_played.substr(10))
	return a_date < b_date

func is_newer(a: RetroHubGameData, b: RetroHubGameData):
	var a_date := int(a.last_played.substr(0, 8) + a.last_played.substr(10))
	var b_date := int(b.last_played.substr(0, 8) + b.last_played.substr(10))
	return a_date > b_date

func _on_game_received(data: RetroHubGameData):
	if not data.last_played.is_empty():
		# Still hasn't reached the max amount of games
		if len(games) < max_displayed_games:
			games.push_back(data)
		else:
			# Replace the oldest game; sorting comes later
			var oldest = games.reduce(func(min, val): return val if is_older(val, min) else min)
			games[games.find(oldest)] = data

func _on_game_receive_end():
	games.sort_custom(is_newer)
	for game in games:
		var preview = game_preview.instantiate()
		n_container.add_child(preview)
		preview.game_data = game
