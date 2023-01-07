extends Control

onready var n_sort_by := $"%SortBy"

func grab_focus():
	n_sort_by.grab_focus()
