class_name EnemyBase extends CharacterBody2D

signal health_changed(current_health: float, max_health: int)

enum Type {
	KAMIKAZE,
}

@export var speed: float = 100.0
@export var base_damage: int
@export var max_health: int :
	set(value):
		max_health = value
		health_changed.emit(current_health, max_health)
		
@export var hurt_time: float # Invulnerability time after getting hit once
## Distance the enemy gets knocked back when taking non jam damage
@export var knockback_distance: float
## This is the time it takes for the enemy to go there full knockback_distance
@export var knockback_time: float = 0.2

var current_health: float :
	set(value):
		current_health = value
		health_changed.emit(current_health, max_health)

var is_hurt: bool = false # Is the enemy invulnerable

var type: Type

var _navigation_ready := false

var player: Player

@onready var hurt_timer: Timer = $HurtTimer
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player_enter: Area2D = $PlayerEnter
@onready var player_exit: Area2D = $PlayerExit

func _ready() -> void:
	current_health = max_health
	player_enter.body_entered.connect(_on_player_entered)
	player_exit.body_exited.connect(_on_player_exited)
	setup_navigation_agent()

	
func setup_navigation_agent() -> void:
	navigation_agent.avoidance_enabled = false # Avoidance will need to be enabled by the class that inherits EnemyBase
	navigation_agent.max_speed = speed
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	set_deferred("_navigation_ready", true)
	

# Returns whether or not navigation is complete
func follow_point(point_position: Vector2) -> bool:
	if !_navigation_ready:
		return false
	navigation_agent.set_target_position(point_position)
	
	if navigation_agent.is_navigation_finished():
		return true

	var next_path_position := navigation_agent.get_next_path_position()
	var new_velocity := global_position.direction_to(next_path_position) * speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
	
	return false


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	Global.tile_map.place_mold_g(global_position)
	move_and_slide()
	

func _on_player_entered(body: Node2D) -> void:
	if !(body is Player):
		return
	player = body


func _on_player_exited(body: Node2D) -> void:
	if !(body is Player):
		return
	player = null


func take_damage(damage: float, damage_position: Vector2, is_jam: bool = false) -> void:
	if is_hurt && !is_jam: # Invulnerability
		return
	if is_jam:
		set_modulate(Color.MAGENTA)
	else:
		set_modulate(Color.RED)
		# knockback
		var knockback_dir: Vector2 = damage_position.direction_to(global_position)
		var pos_tween: Tween = create_tween()
		pos_tween.tween_property(self, "global_position", global_position + knockback_dir * knockback_distance, knockback_time)
	is_hurt = true
	
	current_health -= damage
	if current_health <= 0:
		die()
		
	hurt_timer.start(hurt_time)
	await hurt_timer.timeout
	is_hurt = false
	set_modulate(Color.WHITE)
	
		
func die() -> void:
	pass # To be implemented by inherited class
