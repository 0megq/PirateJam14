extends Player


func _physics_process(_delta: float) -> void:
	global_position = get_global_mouse_position()


func take_damage(dmg: int) -> void:
	print("test_player: taking %s damage" % dmg)
