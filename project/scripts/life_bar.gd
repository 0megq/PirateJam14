extends Control

const heart_scene: PackedScene = preload("res://scenes/life_bar_heart.tscn")


func _ready() -> void:
	Global.player.lives_changed.connect(_on_player_lives_changed)


func _on_player_lives_changed(current_lives: int, _max_lives: int):
	for extra_life in get_child_count() - current_lives: # Remove extra lives
		get_child(extra_life).queue_free()
	
	for new_life in current_lives - get_child_count(): # Add new lives
		new_heart()


func new_heart() -> void:
	var heart: TextureRect = heart_scene.instantiate()
	add_child(heart)
