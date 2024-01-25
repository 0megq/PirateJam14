extends CanvasLayer


func _on_pause_menu_about_to_popup() -> void:
	get_tree().paused = true

func _on_pause_menu_popup_hide() -> void:
	get_tree().paused = false

func update_enemy_cursor(screen_pos: Vector2) -> void:
	$EnemyCursor.update(screen_pos)
