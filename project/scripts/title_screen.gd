extends Control

signal play_pressed
signal play_level(level: int)

var total_levels: int = 0 :
	set(value):
		total_levels = value
		level_select_panel.update(total_levels)

@onready var controls_panel = $MarginContainer/VBoxContainer/HBoxContainer/Controls/Background/Image
@onready var options_panel = $MarginContainer/VBoxContainer/HBoxContainer/Controls/Background/Panel
@onready var level_select_panel = $MarginContainer/VBoxContainer/HBoxContainer/Controls/Background/LevelSelectPanel

@onready var background = $Background
@onready var panel = $MarginContainer/VBoxContainer/HBoxContainer/Controls/Background


func _ready() -> void:
	$Background.modulate = Color(0.9,0.9,0.9)
	$Background2/AnimationPlayer.play("parallax_fade_in")


func _on_play_pressed() -> void:
	play_pressed.emit()


func _on_level_select_pressed() -> void:
	level_select_panel.visible = !level_select_panel.visible
	if level_select_panel.visible:
		background.modulate = Color(0.9,0.9,0.9)
	else:
		background.modulate = Color(0.5,0.5,0.5)
	options_panel.hide()
	controls_panel.hide()
	
	
func _on_controls_pressed() -> void:
	controls_panel.visible = !controls_panel.visible
	if controls_panel.visible:
		background.modulate = Color(0.9,0.9,0.9)
	else:
		background.modulate = Color(0.5,0.5,0.5)
	options_panel.hide()
	level_select_panel.hide()


func _on_options_pressed() -> void:
	options_panel.visible = !options_panel.visible
	if options_panel.visible:
		background.modulate = Color(0.9,0.9,0.9)
	else:
		background.modulate = Color(0.5,0.5,0.5)
	controls_panel.hide()
	level_select_panel.hide()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_level_select_panel_level_selected(level: int) -> void:
	play_level.emit(level)
