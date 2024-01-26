extends Node


const levels: Array[PackedScene] = [preload("res://scenes/level_1.tscn")]

var current_level_number: int = 0
var current_level: Level


func _on_title_screen_play_pressed() -> void:
	play()


func play() -> void:
	current_level = levels[current_level_number].instantiate()
	add_child(current_level)
	current_level.retry_level.connect(retry_current_level)
	current_level.quit_level.connect(quit_level)
	current_level.next_level.connect(next_level)
	$TitleLayer.hide()


func quit_level() -> void:
	current_level.queue_free()
	$TitleLayer.show()
	

func retry_current_level() -> void:
	current_level.queue_free()
	current_level = levels[current_level_number].instantiate()
	add_child(current_level)


func next_level() -> void:
	current_level.queue_free()
	if current_level_number + 1 < levels.size():
		current_level_number += 1
		current_level = levels[current_level_number].instantiate()
		add_child(current_level)
	else:
		$TitleLayer.show()
		print("last level reached play credits here")
