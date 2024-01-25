extends Node


const levels: Array[PackedScene] = [preload("res://scenes/level_1.tscn")]


func _on_title_screen_play_pressed() -> void:
	add_child(levels[0].instantiate())
	$TitleLayer.hide()
