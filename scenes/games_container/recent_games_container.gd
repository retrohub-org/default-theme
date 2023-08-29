extends VBoxContainer

signal focus_top_element

@export var game_preview : PackedScene
@export var max_displayed_games := 5

@onready var n_container := %Container

var prev_container : Control
var next_container : Control
var last_input : InputEvent

var games : Array[RetroHubGameData] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.game_received.connect(_on_game_received)
	RetroHub.game_receive_end.connect(_on_game_receive_end)

func _input(event):
	last_input = event

func is_older(a: RetroHubGameData, b: RetroHubGameData):
	var a_date := int(a.last_played.substr(0, 8) + a.last_played.substr(9))
	var b_date := int(b.last_played.substr(0, 8) + b.last_played.substr(9))
	return a_date < b_date

func is_newer(a: RetroHubGameData, b: RetroHubGameData):
	var a_date := int(a.last_played.substr(0, 8) + a.last_played.substr(9))
	var b_date := int(b.last_played.substr(0, 8) + b.last_played.substr(9))
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
	if games.is_empty():
		visible = false
		return

	games.sort_custom(is_newer)
	for game in games:
		var preview : Control = game_preview.instantiate()
		n_container.add_child(preview)
		preview.game_data = game
		preview.set_focus_neighbor_bottom("../../../FocusHandlerBottom")
		preview.set_focus_neighbor_top("../../../FocusHandlerTop")

func grab_first_focus() -> bool:
	if not visible or n_container.get_child_count() < 1: return false
	grab_first_child()
	return true

func grab_first_child():
	for child in n_container.get_children():
		if child.visible:
			child.grab_focus()
			return

func grab_last_child():
	var children = n_container.get_children()
	children.reverse()
	for child in children:
		if child.visible:
			child.grab_focus()
			return

func reset_visibility():
	for child in n_container.get_children():
		child.visible = true
	visible = true

func determine_self_visibility():
	for child in n_container.get_children():
		if child.visible:
			visible = true
			return
	visible = false

func determine_child_visibility(child: Node, term: String):
	var game_data : RetroHubGameData = child.game_data
	var game_name := game_data.name

	child.visible = game_name.to_lower().contains(term.to_lower())

func search_requested(term: String):
	if term.is_empty():
		reset_visibility()
		return

	for child in n_container.get_children():
		determine_child_visibility(child, term)
	determine_self_visibility()


func search_add_requested(term: String):
	if term.is_empty():
		reset_visibility()
		return

	for child in n_container.get_children():
		if child.visible == false: continue
		determine_child_visibility(child, term)
	determine_self_visibility()

func search_sub_requested(term: String):
	if term.is_empty():
		reset_visibility()
		return

	for child in n_container.get_children():
		if child.visible == true: continue
		determine_child_visibility(child, term)
	determine_self_visibility()

func grab_focus_bottom():
	if last_input:
		if last_input.is_action("ui_up"):
			var last_child : Control
			for idx in range(n_container.get_child_count()-1, -1, -1):
				if not last_child:
					last_child = n_container.get_child(idx)
					if not last_child.visible:
						last_child = null
					continue
				var child = n_container.get_child(idx)
				if not child.visible: continue
				if n_container.get_child(idx).position.y < last_child.position.y:
					last_child.grab_focus()
					return
				last_child = n_container.get_child(idx)
			last_child.grab_focus()
		elif last_input.is_action("ui_down"):
			if next_container:
				next_container.grab_focus_top()
			else:
				grab_last_child()
		else:
			grab_first_child()


func _on_focus_handler_bottom_focus_entered():
	grab_focus_bottom()


func _on_focus_handler_top_focus_entered():
	if last_input:
		if last_input.is_action("ui_up"):
			focus_top_element.emit()
		else:
			grab_first_child()
