class_name Player
extends CharacterBody2D

signal health_changed(current_health: int, max_health: int)


# Exports
@export var max_speed: float = 200.0 # Speed & acceleration may need to be tweaked
@export var acceleration: float = 2000.0

@export var attack_interval: float = 0.6 # Time between attacks
@export var attack_duration: float = 0.1 # How long attack hitbox is out
@export var base_damage: int = 5
@export var jam_container: Node
@export var fire_offset: float = 10

@export var max_health: int = 30



# Normal
var jam_projectile_scene = preload("res://scenes/jam.tscn")

var is_hurt: bool = false

var can_attack: bool = true
var attack_input: bool = false
var reload_input: bool = false

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
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var hurt_timer: Timer = $HurtTimer
@onready var attack_interval_timer: Timer = $AttackIntervalTimer
@onready var attack_duration_timer: Timer = $AttackDurationTimer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var cursor: Sprite2D = $Cursor


func _ready() -> void:
	set_deferred("current_health", max_health)


func _physics_process(delta: float) -> void:
	input()
	
	animate()
	
	move(delta)
	manage_attack()

# Gets input and stores in the appropriate input variables
func input() -> void:
	dir_input = Input.get_vector("left", "right", "up", "down")
	attack_input = Input.is_action_pressed("attack")
	reload_input = Input.is_action_pressed("reload")
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
			cursor.rotation = js_r_input.angle()
			cursor.position = aim_dir
		else:
			pass

		if dir_input == Vector2.ZERO:
			animation_tree.get("parameters/playback").travel("Idle")
			animation_tree.set("parameters/Idle/blend_position", cursor.position)
		else:
			animation_tree.get("parameters/playback").travel("Walking")
			animation_tree.set("parameters/Walking/blend_position", dir_input)
	#Mouse & Keyboard
	else:
		cursor.rotation = mouse_dir.angle()
		cursor.position = clamp(mouse_position, mouse_dir * 20, mouse_dir * 20)
		if dir_input == Vector2.ZERO:
			animation_tree.get("parameters/playback").travel("Idle")
			animation_tree.set("parameters/Idle/blend_position", mouse_dir)
		else:
			animation_tree.get("parameters/playback").travel("Walking")
			animation_tree.set("parameters/Walking/blend_position", dir_input)


# Moves the player (duh)
func move(delta: float) -> void:
	#Movementa
	velocity = velocity.move_toward(dir_input * max_speed, acceleration * delta)
	
	#Removes speed-down before speeding back up. Satisfying :D
	if dir_input == Vector2(0,0):
		velocity = Vector2(0,0)
	
	move_and_slide()


func reload() -> void:
	print("reload functionality goes here")


func manage_attack() -> void:	
	# Attacking
	if attack_input and can_attack:
		can_attack = false
		attack()
		attack_interval_timer.start(attack_interval)


func _on_attack_interval_timer_timeout() -> void:
	can_attack = true


func attack() -> void:
	# Hitbox rotation
	var mouse_dir := global_position.direction_to(get_global_mouse_position())
	var joystick_r_dir := Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)).normalized()
	
	var aim_dir: Vector2
	if Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT): # Check for controller input
		aim_dir = joystick_r_dir
	else:
		aim_dir = mouse_dir
		
	attack_hitbox.rotation = aim_dir.angle()
	
	# Turn hitbox on
	$AttackHitbox/AttackDisplay.show()
	attack_hitbox.monitoring = true
	attack_duration_timer.start(attack_duration)


func _on_attack_duration_timer_timeout() -> void:
	# Turn hit box off
	$AttackHitbox/AttackDisplay.hide()
	attack_hitbox.monitoring = false
	

func _on_attack_area_body_entered(body: Node2D) -> void:
	# Damage enemy
	if body is EnemyBase:
		body.take_damage(base_damage)


# Fires jam
#func fire() -> void:
	## Setup jam
	#var jam: CPUParticles2D = jam_projectile_scene.instantiate()
		#
	#jam.visible = true
	#jam.global_position = global_position
	#jam.emitting = true
	#jam_container.add_child(jam)
	#
	## Jam rotation and offset
	#var mouse_dir := global_position.direction_to(get_global_mouse_position())
	#var joystick_r_dir := Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)).normalized()
	#
	#var aim_dir: Vector2
	#if Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT): # Check for controller input
		#aim_dir = joystick_r_dir
	#else:
		#aim_dir = mouse_dir
		#
	#jam.rotation = aim_dir.angle()
	#jam.global_position += (aim_dir + velocity.normalized()) * fire_offset # Offset the jam by the aim direction and velocity
	#
	## Count particles
	#particle_count += jam.amount


func take_damage(dmg: int) -> void:
	current_health -= dmg
	is_hurt = true
	
	if current_health <= 0:
		die()
	
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
