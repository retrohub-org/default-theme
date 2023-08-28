extends VBoxContainer

@export var game_preview : PackedScene

@onready var n_container := %Container

var next_container : Control
var prev_container : Control
var last_input : InputEvent

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.game_received.connect(_on_game_received)
	RetroHub.game_receive_end.connect(_on_game_receive_end)

func _input(event):
	last_input = event

func _on_game_received(data: RetroHubGameData):
	if data.favorite:
		var preview = game_preview.instantiate()
		n_container.add_child(preview)
		preview.game_data = data

func _on_game_receive_end():
	visible = n_container.get_child_count() > 0

func grab_first_focus() -> bool:
	if not visible or n_container.get_child_count() < 0: return false
	n_container.get_child(0).grab_focus()
	return true

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

func grab_focus_top():
	if last_input:
		if last_input.is_action("ui_up") and prev_container:
			prev_container.grab_focus_bottom()
		if last_input.is_action("ui_down"):
			n_container.get_child(0).grab_focus()

func grab_focus_bottom():
	if last_input:
		if last_input.is_action("ui_up"):
			var last_child : Control
			for idx in range(n_container.get_child_count()-1, -1, -1):
				if not last_child:
					last_child = n_container.get_child(idx)
					continue
				if n_container.get_child(idx).position.y < last_child.position.y:
					last_child.grab_focus()
					return
				last_child = n_container.get_child(idx)
			last_child.grab_focus()
		if last_input.is_action("ui_down") and next_container:
			next_container.grab_focus_top()


func _on_focus_handler_top_focus_entered():
	grab_focus_top()

func _on_focus_handler_bottom_focus_entered():
	grab_focus_bottom()