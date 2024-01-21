extends Popup


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		hide()


func _on_resume_pressed() -> void:
	hide()


func _on_yes_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func _on_quit_pressed() -> void:
	$Pausing/Quitting.popup()


func _on_no_pressed() -> void:
	$Pausing/Quitting.hide()



func _on_options_pressed() -> void:
	$OptionsMenu.popup()


func _on_savesettings_pressed() -> void:
	$OptionsMenu.hide()
