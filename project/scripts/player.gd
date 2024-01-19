class_name Player
extends CharacterBody2D

signal health_changed(current_health: int, max_health: int)
signal ammo_changed(current_ammo: int, max_ammo: int)


# Exports
@export var max_speed: float = 200.0 # Speed & acceleration may need to be tweaked
@export var acceleration: float = 2000.0

@export var attack_interval: float = 0.6 # Time between attacks
@export var attack_duration: float = 0.3 # How long attack hitbox is out
@export var base_damage: int = 5
@export var max_ammo: int = 6 : 
	set(value):
		max_ammo = value
		ammo_changed.emit(current_ammo, max_ammo)
		
@export var jam_container: Node

@export var max_health: int = 30 : 
	set(value):
		max_health = value
		health_changed.emit(current_health, max_health)

# Normal
var jam_projectile_scene = preload("res://scenes/jam.tscn")

var is_hurt: bool = false

var can_attack: bool = true
var attack_input: bool = false
var reload_input: bool = false

var attack_look: bool = false

var dir_input: Vector2
var js_r_input: Vector2
var joypad: bool

var current_ammo: int :
	set(value):
		current_ammo = value
		ammo_changed.emit(current_ammo, max_ammo)

var current_health: int :
	set(value):
		current_health = value
		health_changed.emit(current_health, max_health)

# Onready
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var hurt_timer: Timer = $HurtTimer
@onready var attack_interval_timer: Timer = $AttackIntervalTimer
@onready var attack_duration_timer: Timer = $AttackDurationTimer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var cursor: Sprite2D = $Cursor
@onready var attack_look_timer: Timer = $AttackLookTimer

func _ready() -> void:
	set_deferred("current_ammo", max_ammo)
	set_deferred("current_health", max_health)


func _physics_process(delta: float) -> void:
	detect_controls()
	
	input()
	animate()
	move(delta)
	manage_attack()
	
	
func detect_controls() -> void:
	var mouse_position = get_global_mouse_position()
	var mouse_dir := global_position.direction_to(mouse_position)
	var js_r_position = js_r_input.normalized()
	#Controller
	if joypad:
		if js_r_input != Vector2.ZERO:
			cursor.position = clamp(js_r_position, js_r_position * 20, js_r_position * 20)
			cursor.rotation = js_r_input.angle()
	#Mouse & Keyboard
	else:
		cursor.rotation = mouse_dir.angle()
		cursor.position = clamp(mouse_position, mouse_dir * 20, mouse_dir * 20)
		
		
# Gets input and stores in the appropriate input variables
func input() -> void:
	dir_input = Input.get_vector("left", "right", "up", "down")
	attack_input = Input.is_action_pressed("attack")
	reload_input = Input.is_action_pressed("reload")
	js_r_input = Input.get_vector("aim_left","aim_right","aim_up","aim_down")


# Animates player based off cursor position
func animate() -> void:
	if dir_input == Vector2.ZERO:
		animation_tree.get("parameters/playback").travel("Idle")
		animation_tree.set("parameters/Idle/blend_position", cursor.position)
	elif attack_look:
		animation_tree.get("parameters/playback").travel("Walking")
		animation_tree.set("parameters/Walking/blend_position", cursor.position)
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
	# Replace this with some sort of reload animation
	print("reload functionality goes here")
	# Refill ammo. Placeholder: Current ammo should increase by one based off a certain frame of the animation
	# Also slow down player
	current_ammo = max_ammo


func manage_attack() -> void:	
	# Attacking
	if attack_input and can_attack:
		attack_look = true
		can_attack = false
		attack()
		attack_interval_timer.start(attack_interval)
		attack_look_timer.start(.3)
		await attack_look_timer.timeout
		attack_look = false

func _on_attack_interval_timer_timeout() -> void:
	can_attack = true


func attack() -> void:	
	var aim_dir: Vector2 = cursor.position
		
	attack_hitbox.rotation = aim_dir.angle()
	# Turn hitbox on
	#$AttackHitbox/AttackDisplay.show()
	$AttackHitbox/SwordSprite.show()
	$AnimationPlayer.play("attack")
	attack_hitbox.monitoring = true
	attack_duration_timer.start(attack_duration)
	
	if current_ammo > 0:
		current_ammo -= 1
		$AnimationPlayer.play("jelly_attack")
		fire_jam()


func _on_attack_duration_timer_timeout() -> void:
	# Turn hit box off
	#$AttackHitbox/AttackDisplay.hide()
	$AttackHitbox/SwordSprite.hide()
	$AnimationPlayer.stop()
	attack_hitbox.monitoring = false


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(base_damage)


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		area.take_damage(base_damage)


 #Fires jam
func fire_jam() -> void:
	# Setup jam
	var jam: GPUParticles2D = jam_projectile_scene.instantiate()
	
	jam.visible = true
	jam.restart()
	jam_container.add_child(jam)
	
	# Jam rotation and offset
	jam.rotation = cursor.position.angle()
	jam.global_position = cursor.global_position


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

