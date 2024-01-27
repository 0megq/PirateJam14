extends PanelContainer

signal level_selected(level: int)

const level_button: PackedScene = preload("res://scenes/level_select_button.tscn")


func update(total_levels: int) -> void:
	for child in $GridContainer.get_children():
		child.queue_free()
		
	for level in total_levels:
		var button: Button = level_button.instantiate()
		button.text = str(level + 1)
		$GridContainer.add_child(button)
		button.pressed.connect(_on_level_button_pressed.bind(level))


func _on_level_button_pressed(level: int) -> void:
	level_selected.emit(level)
