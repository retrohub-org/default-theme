extends Control

var data : RetroHubGameData

@onready var n_media_root := %Media
@onready var n_data_root := %Data

@onready var media_orig_rect : Rect2 = n_media_root.get_rect()
@onready var data_orig_rect : Rect2 = n_data_root.get_rect()

var media_expanded := false

func _on_game_pressed(data: RetroHubGameData):
	visible = true
	self.data = data

	_on_data_focus_entered(0.0)
	n_data_root.game_data = data
	n_media_root.game_data = data

func _on_back_pressed():
	if media_expanded:
		_on_data_focus_entered()
	else:
		visible = false

func _on_media_focus_entered():
	if media_expanded: return

	# Give media more by expanding it's size
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)

	tween.tween_property(n_media_root, "size:y", 648 * 0.8, 0.3)
	tween.tween_property(n_data_root, "position:y", 648 * 0.8, 0.3)

	# Re-order media elements
	n_media_root.animate_enter(0.3)

	media_expanded = true

func _on_data_focus_entered(time := 0.3):
	# Restore original layout
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)

	tween.tween_property(n_media_root, "size:y", media_orig_rect.size.y, time)
	tween.tween_property(n_data_root, "position:y", data_orig_rect.position.y, time)

	# Re-order media elements
	n_media_root.animate_exit(time)

	# Make play grab focus
	n_data_root.grab_focus()

	media_expanded = false

func _on_play_pressed():
	RetroHub.launch_game()
