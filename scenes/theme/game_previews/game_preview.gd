extends Control

signal game_preview_selected(data: RetroHubGameData, select_on_ui: bool)
signal game_pressed(data: RetroHubGameData, preview: Control)

var n_preview_scene := preload("res://scenes/theme/game_previews/game_preview_button.tscn")
var n_preview : Button

@onready var min_y := -50
@onready var max_y := get_viewport().get_visible_rect().size.y + 50

var game_data : RetroHubGameData:
	set(value):
		game_data = value

var last_global_y := global_position.y
func _process(_delta):
	if game_data:
		var global_y := global_position.y
		var delta = global_y - last_global_y
		last_global_y = global_y

		# Handle behavior differently if currently loaded or not
		if n_preview:
			check_unload_preview(global_y)
		else:
			check_load_preview(global_y, delta)

# Check if we should unload preview
func check_unload_preview(y: float):
	# Unload if we leave the limits
	if y + size.y < min_y or y > max_y:
		n_preview.queue_free()
		n_preview = null

func check_load_preview(y: float, delta: float):
	# Load if we are inside the limits
	if y + size.y >= min_y and y <= max_y:
		n_preview = n_preview_scene.instantiate()
		n_preview.pressed.connect(_on_game_preview_button_pressed.bind(n_preview))
		n_preview.mouse_entered.connect(_on_game_preview_focused.bind(false))
		n_preview.focus_entered.connect(_on_game_preview_focused.bind(true))
		add_child(n_preview)
		n_preview.game_data = game_data
		if has_focus():
			_on_focus_entered()

func _on_game_preview_focused(select_on_ui: bool):
	game_preview_selected.emit(game_data, select_on_ui)
	get_tree().call_group("global_signal(on_game_preview_selected)", "_on_game_preview_selected", game_data, select_on_ui)


func _on_game_preview_button_pressed(preview: Button):
	game_pressed.emit(game_data, preview)
	get_tree().call_group("global_signal(on_game_pressed)", "_on_game_pressed", game_data, preview)

func _on_focus_entered():
	if n_preview:
		n_preview.grab_focus()
