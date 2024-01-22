extends Control

@onready var controls_panel = $MarginContainer/VBoxContainer/HBoxContainer/Controls/Background/Image
@onready var options_panel = $MarginContainer/VBoxContainer/HBoxContainer/Controls/Background/Panel
@onready var options_sliders = $MarginContainer/VBoxContainer/HBoxContainer/Controls/Background/Panel/Sliders
@onready var background = $Background
@onready var panel = $MarginContainer/VBoxContainer/HBoxContainer/Controls/Background
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Background.modulate = Color(0.9,0.9,0.9)
	$Background2/AnimationPlayer.play("parallax_fade_in")


func _on_controls_pressed() -> void:
	options_sliders.hide()
	controls_panel.show()
	background.modulate = Color(0.5,0.5,0.5)


func _on_controls_focus_exited() -> void:
	controls_panel.hide()
	background.modulate = Color(0.9,0.9,0.9)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://tests/testing_scene.tscn")


func _on_options_pressed() -> void:
	options_panel.show()
	options_sliders.show()
	background.modulate = Color(0.5,0.5,0.5)

func _on_options_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		options_panel.hide()
		background.modulate = Color(0.9,0.9,0.9)
	elif event.is_action_pressed("ui_down"):
		options_panel.hide()
		background.modulate = Color(0.9,0.9,0.9)	


func _on_play_focus_entered() -> void:
	if options_panel:
		options_panel.hide()
	$Background.modulate = Color(0.9,0.9,0.9)

func _on_quit_pressed() -> void:
	get_tree().quit()
	
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_focus_next"):
		#$Background2/AnimationPlayer.play("parallax_fade_in")
