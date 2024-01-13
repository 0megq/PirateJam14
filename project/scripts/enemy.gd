class_name Enemy extends CharacterBody2D


@export var speed: float = 100.0
var navigation_ready := false

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	setup_navigation_agent()


func _physics_process(delta: float) -> void:
	if navigation_ready:
		follow_player(get_global_mouse_position())
	
	
func setup_navigation_agent() -> void:
	navigation_agent.max_speed = speed
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	set_deferred("navigation_ready", true)
	
	
func follow_player(player_position: Vector2) -> void:
	navigation_agent.set_target_position(player_position)
	
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
