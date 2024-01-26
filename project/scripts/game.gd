extends Node


const levels: Array[PackedScene] = [preload("res://scenes/level_1.tscn")]

var current_level_number: int = 0
var current_level: Level


@onready var pause_menu := $PauseLayer/PauseMenu
@onready var title_screen := $TitleLayer/TitleScreen

func _ready() -> void:
	pause_menu.quit.connect(quit_level)
	pause_menu.resume.connect(resume_level)
	title_screen.total_levels = levels.size()


func _on_title_screen_play_pressed() -> void:
	play()


func _on_title_screen_play_level(level: int) -> void:
	current_level_number = level
	play()


func play() -> void:
	current_level = levels[current_level_number].instantiate()
	add_child(current_level)
	current_level.retry_level.connect(retry_current_level)
	current_level.quit_level.connect(quit_level)
	current_level.next_level.connect(next_level)
	title_screen.hide()


func quit_level() -> void:
	pause_menu.hide()
	current_level.queue_free()
	current_level = null
	title_screen.show()
	

func retry_current_level() -> void:
	current_level.queue_free()
	play()


func next_level() -> void:
	current_level.queue_free()
	if current_level_number + 1 < levels.size():
		current_level_number += 1
		play()
	else:
		current_level = null
		# PLACEHOLDER CODE
		title_screen.show()
		print("last level reached play credits here")


func resume_level() -> void:
	pause_menu.hide()
	current_level.process_mode = Node.PROCESS_MODE_INHERIT


func pause_level() -> void:
	# If already paused then unpause
	if pause_menu.visible:
		resume_level()
		return
	pause_menu.show()
	pause_menu.open()
	current_level.process_mode = Node.PROCESS_MODE_DISABLED
	

func _input(event: InputEvent) -> void:
	if current_level && event.is_action_pressed("pause"):
		pause_level()
