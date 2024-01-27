extends Sprite2D

const padding: Vector2 = Vector2(8, 8)


func update(screen_pos: Vector2) -> void:
	var viewport_size := get_viewport_rect().size
	screen_pos += viewport_size / 2 # Set origin to top left
	
	position = screen_pos.clamp(Vector2.ZERO + padding, viewport_size - padding)
	
	# Check if the screen position is visible on screen and hide if so
	show()
	if screen_pos == position:
		hide()
		return
	look_at(screen_pos)
