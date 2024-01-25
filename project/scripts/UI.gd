extends CanvasLayer

@onready var pause_menu: Node = $PauseMenu

var is_paused: bool = false

func _ready() -> void:
	pause_menu.hide()
 
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_menu.popup()


func _on_pause_menu_about_to_popup() -> void:
	get_tree().paused = true

func _on_pause_menu_popup_hide() -> void:
	get_tree().paused = false

func update_enemy_cursor(screen_pos: Vector2) -> void:
	$EnemyCursor.update(screen_pos)
