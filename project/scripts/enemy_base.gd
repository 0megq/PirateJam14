class_name EnemyBase extends CharacterBody2D

@export var speed: float = 100.0

var _navigation_ready := false

var player: Node2D # Change this to Player class later

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player_detector: Area2D = $PlayerDetector

func _ready() -> void:
	player_detector.body_entered.connect(_on_player_entered)
	player_detector.body_exited.connect(_on_player_exited)
	setup_navigation_agent()

	
func setup_navigation_agent() -> void:
	navigation_agent.avoidance_enabled = false # Avoidance will need to be enabled by the class that inherits EnemyBase
	navigation_agent.max_speed = speed
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	set_deferred("_navigation_ready", true)
	
	
func follow_point(point_position: Vector2) -> void:
	if !_navigation_ready:
		return
	navigation_agent.set_target_position(point_position)
	
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position := navigation_agent.get_next_path_position()
	var new_velocity := global_position.direction_to(next_path_position) * speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_player_entered(body: Node2D) -> void:
	# check for player here
	player = body


func _on_player_exited(body: Node2D) -> void:
	# check for player here
	player = null
