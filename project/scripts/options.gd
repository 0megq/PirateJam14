extends Control

@onready var master_v_slider: Node = $HBoxContainer/Master/MasterVSlider
@onready var music_v_slider: Node = $HBoxContainer/Music/MusicVSlider
@onready var sounds_v_slider: Node = $HBoxContainer/Sounds/SoundsVSlider
var music := AudioServer.get_bus_index("Music")
var master := AudioServer.get_bus_index("Master")
var sounds := AudioServer.get_bus_index("Sounds")

var musiclevel := db_to_linear(AudioServer.get_bus_volume_db(music))
var masterlevel := db_to_linear(AudioServer.get_bus_volume_db(master))
var soundslevel := db_to_linear(AudioServer.get_bus_volume_db(sounds))

func _ready() -> void:
	master_v_slider.value = masterlevel
	music_v_slider.value = musiclevel
	sounds_v_slider.value = soundslevel


func _on_master_v_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master, linear_to_db(value))
	print(AudioServer.get_bus_volume_db(master))


func _on_music_v_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music, linear_to_db(value))
	print(AudioServer.get_bus_volume_db(music))


func _on_sounds_v_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sounds, linear_to_db(value))
	print(AudioServer.get_bus_volume_db(sounds))
