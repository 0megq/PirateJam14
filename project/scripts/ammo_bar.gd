extends Control

const jar_scene: PackedScene = preload("res://scenes/ammo_bar_jar.tscn")


func _ready() -> void:
	Global.player.ammo_changed.connect(_on_player_ammo_changed)

func _on_player_ammo_changed(current_ammo: int, max_ammo: int):
	for new_child in (max_ammo - get_child_count()): # Make enough jars for max_ammo
		new_jar()
		
	for child_index in get_child_count():
		var child := get_child(child_index)
		if child_index < current_ammo:
			child.fill()
		else:
			child.empty()


func new_jar() -> void:
	var jar: TextureRect = jar_scene.instantiate()
	add_child(jar)
