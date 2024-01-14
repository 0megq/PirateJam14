extends CPUParticles2D


func _on_splat_timer_timeout() -> void:
	z_index = 0	


func _on_timer_timeout() -> void:
	process_mode = PROCESS_MODE_DISABLED


func _on_decay_timer_timeout() -> void:
	queue_free()
