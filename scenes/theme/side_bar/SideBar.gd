extends ScrollContainer

@onready var n_container := %Container

# Called when the node enters the scene tree for the first time.
func _ready():
	RetroHub.system_received.connect(_on_system_received)


func _on_system_received(data: RetroHubSystemData):
	var btn := Button.new()
	btn.text = data.name
	%Container.add_child(btn)
