extends Popup


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		hide()
