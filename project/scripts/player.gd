class_name Player
extends CharacterBody2D

signal health_changed(current_health: float, max_health: int)
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

## This is damage the enemy would take if they got hit by the entire jam projectile
@export var total_jam_damage: int = 40
		
@export var jam_container: Node

@export var max_health: int = 30 : 
	set(value):
		max_health = value
		health_changed.emit(current_health, max_health)

# Normal
var jam_projectile_scene = preload("res://scenes/jam.tscn")

var is_hurt: bool = false
var reloading: bool = false

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
		#print("%s / %s ammo" % [current_ammo, max_ammo]) prints current_ammo / max_ammo
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
@onready var reload_anim_player: AnimationPlayer = $ReloadAnimationPlayer
@onready var cursor: Sprite2D = $Cursor
@onready var attack_look_timer: Timer = $AttackLookTimer

func _ready() -> void:
	Global.player = self
	set_deferred("current_ammo", max_ammo)
	set_deferred("current_health", max_health)


func _physics_process(delta: float) -> void:
	detect_controls()
	
	input()
	animate()
	sounds()
	manage_reload()
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
	reload_input = Input.is_action_just_pressed("reload")
	js_r_input = Input.get_vector("aim_left","aim_right","aim_up","aim_down")


# Animates player based off cursor position
func animate() -> void:
	if reloading:
		animation_tree.get("parameters/playback").travel("Idle")
		animation_tree.set("parameters/Idle/blend_position", Vector2.DOWN)
	elif dir_input == Vector2.ZERO:
		animation_tree.get("parameters/playback").travel("Idle")
		animation_tree.set("parameters/Idle/blend_position", cursor.position)
	elif attack_look:
		animation_tree.get("parameters/playback").travel("Walking")
		animation_tree.set("parameters/Walking/blend_position", cursor.position)
	else:
		animation_tree.get("parameters/playback").travel("Walking")
		animation_tree.set("parameters/Walking/blend_position", dir_input)


func sounds():
	if velocity.length() > 0:
		if $Footsteps.time_left == 0:
			$AudioStreamPlayer2D.set_pitch_scale(randf_range(0.8, 1.2))
			$AudioStreamPlayer2D.play()
			$Footsteps.start()

# Moves the player (duh)
func move(delta: float) -> void:
	#Movementa
	velocity = velocity.move_toward(dir_input * max_speed, acceleration * delta)
	
	#Removes speed-down before speeding back up. Satisfying :D
	if dir_input == Vector2(0,0):
		velocity = Vector2(0,0)
	
	move_and_slide()


func manage_reload() -> void:
	if current_ammo < max_ammo && reload_input && !reloading: # Start reload
		reloading = true
		reload()
	elif (attack_input || dir_input != Vector2.ZERO) && reloading: # Stop reloading if player is trying to move or attack
		exit_reload()


func reload() -> void:
	# Dont reload if already at max
	if current_ammo >= max_ammo:
		return
		
	# Refill ammo. "reload" animation will call increment_ammo to increase ammo
	reload_anim_player.play("reload_start")


# Increases current_ammo by 1. Used by the reload anim player to increase ammo at a specific frame of the reload animation
func increment_ammo() -> void:
	if current_ammo < max_ammo:
		current_ammo += 1


func exit_reload() -> void:
	reloading = false
	reload_anim_player.play("RESET")


func _on_reload_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "reload_start":
		reload_anim_player.play("reload")
	elif anim_name == "reload":
		if current_ammo < max_ammo:
			reload_anim_player.play("reload")
		else:
			reload_anim_player.play("reload_finish")
	elif anim_name == "reload_finish":
		exit_reload()


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
	if body is EnemyBase:
		body.take_damage(base_damage, global_position)
	elif body.is_in_group("enemy"):
		body.take_damage(base_damage)


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		area.take_damage(base_damage)


 #Fires jam
func fire_jam() -> void:
	# Setup jam
	var jam: Jam = jam_projectile_scene.instantiate()
	
	jam.total_damage = total_jam_damage
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


