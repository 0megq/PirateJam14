extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Background.modulate = Color(0.9,0.9,0.9)


func _on_controls_pressed() -> void:
	$MarginContainer/VBoxContainer/HBoxContainer/Controls/Background/Image.show()
	$Background.modulate = Color(0.5,0.5,0.5)


func _on_controls_focus_exited() -> void:
	$MarginContainer/VBoxContainer/HBoxContainer/Controls/Background/Image.hide()
	$Background.modulate = Color(0.9,0.9,0.9)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://tests/testing_scene.tscn")


func _on_options_pressed() -> void:
	$MarginContainer/VBoxContainer/HBoxContainer/Controls/Background/Options.show()


func _on_options_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		$MarginContainer/VBoxContainer/HBoxContainer/Controls/Background/Options.hide()
	elif event.is_action_pressed("ui_down"):
		$MarginContainer/VBoxContainer/HBoxContainer/Controls/Background/Options.hide()	


func _on_play_focus_entered() -> void:
	$MarginContainer/VBoxContainer/HBoxContainer/Controls/Background/Options.hide()


func _on_quit_pressed() -> void:
	get_tree().quit()
