extends BoxContainer

@onready var progress_bar := $ProgressBar
@onready var value_label := $ValueLabel

func _ready() -> void:
	Global.player.health_changed.connect(_on_player_health_changed)


func _on_player_health_changed(current_health: float, max_health: int):
	progress_bar.value = current_health
	progress_bar.max_value = max_health
	value_label.text = str(current_health) + "/" + str(max_health)
