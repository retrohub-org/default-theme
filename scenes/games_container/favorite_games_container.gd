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
