extends ProgressBar


func _ready() -> void:
	$UpdateTimer.start()
	await $UpdateTimer.timeout
	if Global.tile_map:
		$UpdateTimer.start(Global.tile_map.spread_interval)


func _on_update_timer_timeout() -> void:
	if Global.tile_map:
		value = Global.tile_map.get_mold_percentage()
		$JamBar.value = Global.tile_map.get_jam_percentage()
