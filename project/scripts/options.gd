extends Control

var music = AudioServer.get_bus_index("Music")
var master = AudioServer.get_bus_index("Master")
var sounds = AudioServer.get_bus_index("Sound Effect")


func _on_master_v_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master, linear_to_db(value))


func _on_music_v_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music, linear_to_db(value))


func _on_sounds_v_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sounds, linear_to_db(value))


func _on_options_menu_about_to_popup() -> void:
	grab_focus()
