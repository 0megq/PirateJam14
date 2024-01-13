class_name Player
extends CharacterBody2D
#Speed & Acceleration may need to be tweaked based on other gameplay elements.
const MAX_SPEED: float = 600.0
const ACCELERATION: float = 100.0 


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("Left","Right","Up","Down")
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION)
	#Removes speed-down before speeding back up. Satisfying :D
	if direction == Vector2(0,0):
		velocity = Vector2(0,0)

	move_and_slide()
