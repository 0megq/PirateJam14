extends BoxContainer

@onready var progress_bar := $ProgressBar
@onready var value_label := $ValueLabel


func _on_player_health_changed(current_health: int, max_health: int):
	progress_bar.value = current_health * 100 / max_health
	value_label.text = str(current_health) + "/" + str(max_health)
