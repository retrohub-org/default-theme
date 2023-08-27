extends VBoxContainer

@export var game_preview : PackedScene

@onready var n_system_name := %SystemName
@onready var n_container := %Container

@onready var min_y = -50
@onready var max_y = 648 + 50

var visiblity := false

var system_data : RetroHubSystemData:
	set(value):
		system_data = value
		
		n_system_name.text = system_data.fullname

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.game_received.connect(_on_game_received)

func _process(_delta):
	var global_y := global_position.y

	# Disable children nodes' _process if system is not visible.
	# Saves a ton of wasted computation on large libraries
	var visibility_now = global_y + size.y >= min_y && global_y <= max_y
	if visiblity != visibility_now:
		for child in n_container.get_children():
			child.set_process(visibility_now)
	visiblity = visibility_now

func _on_game_received(data: RetroHubGameData):
	if data.system == system_data:
		var preview = game_preview.instantiate()
		n_container.add_child(preview)
		preview.game_data = data

func reset_visibility():
	for child in n_container.get_children():
		child.visible = true
	visible = true

func determine_child_visibility(child: Node, term: String):
	var game_data : RetroHubGameData = child.game_data
	var game_name := game_data.name

	child.visible = game_name.to_lower().contains(term.to_lower())

func determine_self_visibility():
	for child in n_container.get_children():
		if child.visible:
			visible = true
			return
	visible = false

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
