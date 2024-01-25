extends ColorRect

signal retry_pressed
signal next_pressed
signal quit_pressed


const heart_scene: PackedScene = preload("res://scenes/game_over_heart.tscn")

@onready var heart_container: HBoxContainer = $PanelContainer/VBoxContainer/HeartContainer
@onready var score_label: Label = $PanelContainer/VBoxContainer/Score
@onready var medal_label: Label = $PanelContainer/VBoxContainer/Medal
@onready var bread_health_label: Label = $PanelContainer/VBoxContainer/BreadHealth


#func _ready() -> void:
	#display(14 + 24, [50, 70, 100], 2, 3, 7, 0.76)


func display(score: int, score_per_medal: Array[int], current_lives: int, max_lives: int, score_per_life: int, mold_percent: float) -> void:
	show()
	score_label.text = "Score: %s" % score
	
	if score >= score_per_medal[2]:
		medal_label.text = "Gold"
		medal_label.modulate = Color.GOLD
	elif score >= score_per_medal[1]:
		medal_label.text = "Silver"
		medal_label.modulate = Color.SILVER
	elif score >= score_per_medal[0]:
		medal_label.text = "Bronze"
		medal_label.modulate = Color.DARK_GOLDENROD
	else:
		medal_label.text = "No Medal Earned"
		medal_label.modulate = Color.WHITE

	# Life Container
	for child in heart_container.get_children():
		queue_free()
	for life in max_lives:
		var heart := heart_scene.instantiate()
		heart_container.add_child(heart)
		heart.modulate = Color.BLACK
		heart.hide_score()
	for life in current_lives:
		var heart := heart_container.get_child(life)
		heart.modulate = Color.WHITE
		heart.set_score(score_per_life)
		
	# Bread Health
	bread_health_label.text = "Bread Health: +%.0f" % ((1 - mold_percent) * 100)
	
	
func _on_quit_pressed() -> void:
	quit_pressed.emit()


func _on_retry_pressed() -> void:
	retry_pressed.emit()


func _on_next_pressed() -> void:
	next_pressed.emit()
