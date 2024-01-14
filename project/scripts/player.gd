class_name Player
extends CharacterBody2D

signal health_changed


# Exports
@export var max_speed: float = 200.0 # Speed & acceleration may need to be tweaked
@export var acceleration: float = 2000.0

@export var max_health: int = 30

@export var fire_offset: float = 10

# Normal
var jam_scene = preload("res://scenes/jam.tscn")

var is_hurt: bool = false

var can_fire: bool = true
var fire_input: bool = false
var aim_input: bool = false

var dir_input: Vector2

#debug
var particle_count = 0
#/debug

# Onready
@onready var current_health: int = max_health

@onready var hurt_timer := $HurtTimer
@onready var fire_timer := $FireTimer
@onready var animated_sprite := $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	input()
	
	animate()
	
	move(delta)
	manage_firing()

# Gets input and stores in the appropriate input variables
func input() -> void:
	dir_input = Input.get_vector("left", "right", "up", "down")
	fire_input = Input.is_action_pressed("fire")
	aim_input = Input.is_action_pressed("aim")


# Animates player based off input
func animate() -> void:
	match dir_input: # Match does same thing as if else chain checking if what values match each other. match is also called switch in other languages
		Vector2.RIGHT:
			animated_sprite.play("Idle_Right")
		Vector2.LEFT:
			animated_sprite.play("Idle_Left")
		Vector2.UP:
			animated_sprite.play("Idle_Back")
		Vector2.DOWN:
			animated_sprite.play("Idle_Front")


# Moves the player (duh)
func move(delta: float) -> void:
	#Movementa
	velocity = velocity.move_toward(dir_input * max_speed, acceleration * delta)
	
	#Removes speed-down before speeding back up. Satisfying :D
	if dir_input == Vector2(0,0):
		velocity = Vector2(0,0)
	
	move_and_slide()


# Manages jam firing. 
func manage_firing() -> void:	
	# Firing - modify if/else statements once regular attack is ready.
	if fire_input and aim_input and can_fire:
		can_fire = false
		fire()
		fire_timer.start()
		

# Fires jam
func fire() -> void:
	# Setup jam
	var jam: CPUParticles2D = jam_scene.instantiate()
		
	jam.visible = true
	jam.global_position = global_position
	jam.emitting = true
	get_parent().add_child(jam)
	
	# Jam rotation and offset
	var mouse_dir := global_position.direction_to(get_global_mouse_position())
	var joystick_r_dir := Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)).normalized()
	
	var aim_dir: Vector2
	if Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT): # Check for controller input
		aim_dir = joystick_r_dir
	else:
		aim_dir = mouse_dir
		
	jam.rotation = aim_dir.angle()
	jam.global_position += (aim_dir + velocity.normalized()) * fire_offset # Offset the jam by the aim direction and velocity
	
	# Count particles
	particle_count += jam.amount


# Fire rate timer
func _on_fire_timer_timeout() -> void:
	can_fire = true


func take_damage(dmg: int) -> void:
	current_health -= dmg
	
	if current_health <= 0:
		die()
		
	is_hurt = true
	health_changed.emit()
	
	hurt_timer.start()
	await hurt_timer.timeout
	is_hurt = false

func die() -> void:
	current_health = max_health #PLACEHOLDER!!!! Remove once death mechanic is finished.

#Debug
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		take_damage(3)
		#print(particle_count)
#/debug






