extends ColorRect

# Generic search was requested. No optimization can be done, so this affects
# all existing results.
signal search_requested(term)
# Additive search was requested, meaning new content was added to a previous
# search term. This speeds-up searching, since it only affects included results.
signal search_additive_requested(term)
# Subtractive search was requested, meaning some content was removed to a previous
# search term. This speeds-up searching, since it only affects excluded results.
signal search_subtractive_requested(term)

@onready var n_icon := %Icon
@onready var n_line_edit := %LineEdit
@onready var n_search_delay := %SearchDelay

var last_search_term := ""

var any_game := false

func _ready():
	RetroHub.system_receive_start.connect(func():
		any_game = true
	)

func grab_focus():
	n_line_edit.grab_focus()

func _on_line_edit_text_changed(new_text: String):
	var searching := not new_text.is_empty()
	n_icon.focus_mode = FOCUS_ALL if searching else FOCUS_NONE
	n_icon.disabled = not searching
	n_search_delay.start()

func _on_search_delay_timeout():
	# Only search if there are games
	if not any_game: return
	# Perform a search request
	var search_term : String = n_line_edit.text
	# If any term is empty, reset
	if last_search_term.is_empty() or search_term.is_empty():
		search_requested.emit(search_term)
		print("reset (empty) ", search_term)
	# If last term is a subset of new term, it was done additively
	elif search_term.begins_with(last_search_term):
		search_additive_requested.emit(search_term)
		print("add ", search_term)
	# If new term is a subset of last term, it was done subtractively
	elif last_search_term.begins_with(search_term):
		search_subtractive_requested.emit(search_term)
		print("sub ", search_term)
	# Else we can't optimize this (user may have copy/pasted, selected text then replace, whatever)
	else:
		search_requested.emit(search_term)
		print("reset ", search_term)

	last_search_term = search_term


func _on_icon_pressed():
	n_line_edit.text = ""
	_on_line_edit_text_changed("")
	n_line_edit.grab_focus()


func _on_focus_entered():
	self.grab_focus()
