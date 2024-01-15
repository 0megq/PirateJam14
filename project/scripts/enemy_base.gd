class_name EnemyBase extends CharacterBody2D

enum Type {
	KAMIKAZE,
}

@export var speed: float = 100.0
@export var base_damage: int

var type: Type

var _navigation_ready := false

var player: Player

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player_enter: Area2D = $PlayerEnter
@onready var player_exit: Area2D = $PlayerExit

func _ready() -> void:
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
	place_mold(global_position)
	move_and_slide()

# This needs a more permanent solution. Setting the tile to mold can override jam and the surrounded mold terrain. Perhaps a function that is called on the map itself. That way the map can check if the mold can be placed on that tile
func place_mold(global_pos: Vector2) -> void:
	if !Global.tile_map:
		return
	var map: Map = Global.tile_map
	map.set_cell(map.main_layer, map.local_to_map(map.to_local(global_pos)), 0, map.mold_terrain)


func is_mold(global_pos: Vector2) -> bool:
	if !Global.tile_map:
		return false
	var map: Map = Global.tile_map
	return map.get_cell_atlas_coords(map.main_layer, map.local_to_map(map.to_local(global_pos)), 0) == map.mold_terrain
	

func _on_player_entered(body: Node2D) -> void:
	if !(body is Player):
		return
	player = body


func _on_player_exited(body: Node2D) -> void:
	if !(body is Player):
		return
	player = null
