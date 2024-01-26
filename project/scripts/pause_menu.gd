extends ColorRect

signal resume
signal quit

# Pause Menu
func open() -> void:
	hide_all()
	$PauseMenu.show()
	$PauseMenu/resume.grab_focus()


func _on_resume_pressed() -> void:
	resume.emit()


# Quit menu
func _on_quit_pressed() -> void:
	hide_all()
	$QuitMenu.show()
	$QuitMenu/VBoxContainer/no.grab_focus()


func _on_yes_pressed() -> void:
	quit.emit()


func _on_no_pressed() -> void:
	$QuitMenu.hide()


# Options menu
func _on_options_pressed() -> void:
	hide_all()
	print("hu")
	$OptionsMenu.show()
	$OptionsMenu/Close.grab_focus()


func _on_options_close_pressed() -> void:
	$OptionsMenu.hide()


func hide_all() -> void:
	$PauseMenu.hide()
	$OptionsMenu.hide()
	$QuitMenu.hide()


