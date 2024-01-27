extends Area2D

@export var tutorial: Label


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		tutorial.show()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		tutorial.hide()
