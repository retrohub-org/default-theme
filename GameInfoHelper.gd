extends HBoxContainer

func _ready():
	ControllerIcons.connect("input_type_changed", Callable(self, "_on_input_type_changed"))

func _on_input_type_changed(input_type: int):
	visible = input_type == ControllerIcons.InputType.CONTROLLER
