class_name Player
extends CharacterBody2D

signal health_changed(current_health: int, max_health: int)


# Exports
@export var max_speed: float = 200.0 # Speed & acceleration may need to be tweaked
@export var acceleration: float = 2000.0
@export var jam_container: Node

@export var max_health: int = 30

@export var fire_offset: float = 10

# Normal
var jam_scene = preload("res://scenes/jam.tscn")

var is_hurt: bool = false

var can_fire: bool = true
var is_firing: bool = false
var is_aiming: bool = false

var dir_input: Vector2
var js_r_input: Vector2
var joypad: bool

var current_health: int :
	set(value):
		current_health = value
		health_changed.emit(current_health, max_health)

#debug
var particle_count = 0
#/debug

# Onready
@onready var hurt_timer := $HurtTimer
@onready var fire_timer := $FireTimer


func _ready() -> void:
	set_deferred("current_health", max_health)


func _physics_process(delta: float) -> void:
	input()
	
	animate()
	
	move(delta)
	manage_firing()

# Gets input and stores in the appropriate input variables
func input() -> void:
	dir_input = Input.get_vector("left", "right", "up", "down")
	is_firing = Input.is_action_pressed("fire")
	is_aiming = Input.is_action_pressed("aim")
	js_r_input = Input.get_vector("aim_left","aim_right","aim_up","aim_down")

# Animates player based off input
func animate() -> void:
	var mouse_position = get_global_mouse_position()
	var mouse_dir := global_position.direction_to(mouse_position)
	var js_r_position = js_r_input.normalized()
	#Controller
	if joypad == true:
		if js_r_input != Vector2.ZERO:
			var aim_dir = clamp(js_r_position, js_r_position * 20, js_r_position * 20)
			$Cursor.rotation = js_r_input.angle()
			$Cursor.position = aim_dir
		else:
			pass

		if dir_input == Vector2.ZERO:
			$AnimationTree.get("parameters/playback").travel("Idle")
			$AnimationTree.set("parameters/Idle/blend_position", $Cursor.position)
		else:
			$AnimationTree.get("parameters/playback").travel("Walking")
			$AnimationTree.set("parameters/Walking/blend_position", dir_input)
	#Mouse & Keyboard
	else:
		$Cursor.rotation = mouse_dir.angle()
		$Cursor.position = clamp(mouse_position, mouse_dir * 20, mouse_dir * 20)
		if dir_input == Vector2.ZERO:
			$AnimationTree.get("parameters/playback").travel("Idle")
			$AnimationTree.set("parameters/Idle/blend_position", mouse_dir)
		else:
			$AnimationTree.get("parameters/playback").travel("Walking")
			$AnimationTree.set("parameters/Walking/blend_position", dir_input)


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
	if is_firing and is_aiming and can_fire:
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
	jam_container.add_child(jam)
	
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
	
	hurt_timer.start()
	await hurt_timer.timeout
	is_hurt = false


func die() -> void:
	current_health = max_health #PLACEHOLDER!!!! Remove once death mechanic is finished.


func _input(event: InputEvent) -> void:
	if(event is InputEventJoypadButton) or (event is InputEventJoypadMotion):
		joypad = true
	elif(event is InputEventKey) or (event is InputEventMouseMotion):
		joypad = false






