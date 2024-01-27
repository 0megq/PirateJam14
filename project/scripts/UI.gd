extends CanvasLayer

signal retry_level
signal next_level
signal quit_level


func _ready() -> void:
	$GameOver.hide()
	


func _on_pause_menu_about_to_popup() -> void:
	get_tree().paused = true

func _on_pause_menu_popup_hide() -> void:
	get_tree().paused = false

func update_enemy_cursor(screen_pos: Vector2) -> void:
	$EnemyCursor.update(screen_pos)


func lose() -> void:
	$GameOver.lose()


func game_over(score: int, score_per_medal: Array[int], current_lives: int, max_lives: int, score_per_life: int, mold_percent: float) -> void:
	$GameOver.display_score(score, score_per_medal, current_lives, max_lives, score_per_life, mold_percent)


func _on_game_over_next_pressed() -> void:
	Global.game.next_level()


func _on_game_over_quit_pressed() -> void:
	Global.game.quit_level()


func _on_game_over_retry_pressed() -> void:
	Global.game.retry_current_level()
