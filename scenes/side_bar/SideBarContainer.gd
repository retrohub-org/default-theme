extends VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.system_received.connect(_on_system_received)


func _on_system_received(data: RetroHubSystemData):
	var btn := Button.new()
	btn.text = data.name
	btn.clip_text = true
	btn.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(btn)
