extends Button

signal show_game_info(game_data)

onready var n_label := $"%Label"
onready var n_more_info_root := $"%MoreInfoRoot"
onready var n_play_container := $"%PlayContainer"

var game_data : RetroHubGameData setget set_game_data

func set_game_data(_game_data: RetroHubGameData):
	game_data = _game_data
	n_label.text = game_data.name

func _ready():
	RetroHub.connect("app_returning", self, "_on_app_returning")
	
	RetroHubConfig.connect("game_data_updated", self, "_on_game_data_updated")

func _on_app_returning(_unused: RetroHubSystemData, data: RetroHubGameData):
	if data == game_data:
		yield(get_tree(), "idle_frame")
		print("Grabbing focus")
		grab_focus()

func _on_game_data_updated(data: RetroHubGameData):
	if game_data == data:
		set_game_data(game_data)

func _gui_input(event):
	if event.is_action_pressed("rh_major_option"):
		_on_MoreInfo_pressed()

func _on_GameBoxSimple_focus_entered():
	RetroHub.set_curr_game_data(game_data)
	n_more_info_root.visible = true
	n_play_container.visible = true

func _on_GameBoxSimple_focus_exited():
	n_more_info_root.visible = false
	n_play_container.visible = false

func _on_GameBoxSimple_pressed():
	RetroHub.launch_game()


func _on_MoreInfo_pressed():
	emit_signal("show_game_info", game_data)
