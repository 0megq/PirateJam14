class_name Player
extends CharacterBody2D

signal healthChanged

@onready var hurtTimer := $hurtTimer

#Speed & Acceleration may need to be tweaked based on other gameplay elements, slime, etc.
@export var maxSpeed: float = 800.0
@export var acceleration: float = 200.0 

@export var maxHealth: int = 30
@onready var currentHealth: int = maxHealth
var isHurt: bool = false


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("Left","Right","Up","Down")
	velocity = velocity.move_toward(direction * maxSpeed, acceleration)
	#Removes speed-down before speeding back up. Satisfying :D
	if direction == Vector2(0,0):
		velocity = Vector2(0,0)

	move_and_slide()


func hurtByEnemy(dmg):
	currentHealth -= dmg
	if currentHealth < 0: #PLACEHOLDER!!!! Remove once death mechanic is finished.
		currentHealth = maxHealth 
		
	isHurt = true
	healthChanged.emit()
	
	hurtTimer.start()
	await hurtTimer.timeout
	isHurt = false


#uncomment to test damage by pressing spacebar.
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_accept"):
		#hurtByEnemy(3)




