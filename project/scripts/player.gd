class_name Player
extends CharacterBody2D

signal healthChanged
#timers
@onready var hurtTimer := $hurtTimer
@onready var jamTimer := $jamTimer
@onready var animatedSprite := $AnimatedSprite2D

var scene_JamProjectile = load("res://scenes/jam.tscn")
#Speed & Acceleration may need to be tweaked based on other gameplay elements, slime, size etc.
@export var maxSpeed: float = 800.0
@export var acceleration: float = 200.0 


		
#health
@export var maxHealth: int = 30
@onready var currentHealth: int = maxHealth
var isHurt: bool = false
#states
var isFiring: bool = true
var isAiming: bool = false

#debug
var particleAmount = 0
#/debug

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	
	var direction := Input.get_vector("Left","Right","Up","Down")
	
	#Direction states
	if direction == Vector2.RIGHT:
		animatedSprite.play("Idle_Right")
	elif direction == Vector2.LEFT:
		animatedSprite.play("Idle_Left")
	elif direction == Vector2.UP:
		animatedSprite.play("Idle_Back")
	elif direction == Vector2.DOWN:
		animatedSprite.play("Idle_Front")
	#Movement
	velocity = velocity.move_toward(direction * maxSpeed, acceleration)
	#Removes speed-down before speeding back up. Satisfying :D
	if direction == Vector2(0,0):
		velocity = Vector2(0,0)
	
	move_and_slide()	
	
	#Aiming
	if Input.is_action_pressed("Aim"):
		isAiming = true
	else:
		isAiming = false
		
	#Firing - modify if/else statements once regular attack is ready.
	if Input.is_action_just_pressed("Fire") and isAiming:
		isFiring = true
		fire()
	elif Input.is_action_just_released("Fire"):
		isFiring = false
		


func fire() -> void:
	var jamProjectile = scene_JamProjectile.instantiate()
	var playerPosition: Vector2 = global_position
	var mousePosition:= get_global_mouse_position()
	var joystickDirectionR: Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), 
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		
	jamProjectile.visible = true
	jamProjectile.global_position = playerPosition
	
	#Determines whether or not the player is using a controller for aiming.
	if Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT):
		jamProjectile.rotation = joystickDirectionR.angle()
	else:
		jamProjectile.rotation = global_position.angle_to_point(mousePosition)
	#Shoots the projectile.
	jamProjectile.set_emitting(true)
	get_parent().add_child(jamProjectile)
	particleAmount = particleAmount + 32
	jamTimer.start()


func _on_jam_timer_timeout() -> void:
	if isFiring:
		fire()



func hurtByEnemy(dmg: int) -> void:
	currentHealth -= dmg
	if currentHealth < 0: #PLACEHOLDER!!!! Remove once death mechanic is finished.
		currentHealth = maxHealth 
		
	isHurt = true
	healthChanged.emit()
	
	hurtTimer.start()
	await hurtTimer.timeout
	isHurt = false


#Debug
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		hurtByEnemy(3)
		print(particleAmount)
#/debug






