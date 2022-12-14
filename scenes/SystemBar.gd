extends Control

signal system_selected(data, should_focus)

onready var n_controller_icons := $"%ControllerIcons"
onready var n_label := $"%Label"
onready var n_type_label := $"%TypeLabel"

var system_list := []
var system_idx : int

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.connect("system_receive_start", self, "_on_system_receive_start")
	RetroHub.connect("system_received", self, "_on_system_received")
	RetroHub.connect("game_receive_end", self, "_on_system_receive_end")

	RetroHub.connect("app_returning", self, "_on_app_returning")

func _unhandled_input(event):
	if system_list.size():
		if event.is_action_pressed("rh_left_shoulder", true):
			set_system_idx(system_idx-1, true)
		elif event.is_action_pressed("rh_right_shoulder", true):
			set_system_idx(system_idx+1, true)

func _on_system_receive_start():
	n_controller_icons.modulate.a = 1

func _on_system_received(data: RetroHubSystemData):
	system_list.push_back(data)

func _on_system_receive_end():
	set_system_idx(0, true)

func _on_app_returning(data: RetroHubSystemData, _unused: RetroHubGameData):
	set_system_idx(system_list.find(data), false)

func set_system_idx(_system_idx: int, should_focus: bool):
	if _system_idx < 0:
		system_idx = system_list.size() - 1
	else:
		system_idx = _system_idx % system_list.size()
	var data : RetroHubSystemData = system_list[system_idx]
	n_label.text = data.fullname
	match data.category:
		RetroHubSystemData.Category.Computer:
			n_type_label.text = "(Computer)"
		RetroHubSystemData.Category.Arcade:
			n_type_label.text = "(Arcade)"
		RetroHubSystemData.Category.Console:
			n_type_label.text = "(Console)"
		RetroHubSystemData.Category.GameEngine:
			n_type_label.text = "(Game Engine)"
		RetroHubSystemData.Category.ModernConsole:
			n_type_label.text = "(Modern Console)"
	emit_signal("system_selected", data, should_focus)
