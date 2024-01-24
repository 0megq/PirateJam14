extends Node2D


func _process(delta: float) -> void:
	$TileMap.place_mold_g(0, get_local_mouse_position())
