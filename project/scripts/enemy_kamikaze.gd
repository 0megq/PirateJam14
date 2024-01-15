class_name EnemyKamikaze extends EnemyBase


enum State {
	SPAWN,
	CHASE,
	EXPLODE,
	IDLE,
	WANDER,
	NONE,
}

const max_distance_to_explode: float = 60

const min_wander_dist: float = 40.0
const max_wander_dist: float = 100.0

const min_idle_time: float = 1.0
const max_idle_time: float = 6.0

const max_wander_time: float = 10.0

const min_mold_per_explosion: int = 20

@export var start_state: State

var current_state: State = State.NONE
var wander_point: Vector2

@onready var explosion_radius: float = $ExplosionRadius.shape.radius
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var idle_timer: Timer = $IdleTimer
@onready var wander_timer: Timer = $WanderTimer

func _ready() -> void:
	super()
	type = Type.KAMIKAZE
	idle_timer.timeout.connect(_on_idle_timeout)
	wander_timer.timeout.connect(_on_wander_timeout)
	anim_player.animation_finished.connect(_on_animation_finished)
	change_state(start_state)
	

func _physics_process(_delta: float) -> void:
	change_state(update_state(current_state))


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "RESET":
		return
		
	match current_state:
		State.SPAWN:
			if player:
				change_state(State.CHASE)
			else:
				change_state(State.WANDER)
		State.CHASE:
			pass
		State.EXPLODE:
			explode()
		State.IDLE:
			pass
		State.WANDER:
			pass


# Performs logic based on current state and returns the new state.
func update_state(state: State) -> State:
	match state:
		State.SPAWN:
			pass
		State.CHASE:
			if !player:
				return State.IDLE
			elif global_position.distance_squared_to(player.global_position) > max_distance_to_explode ** 2:
				follow_point(player.global_position)
			else:
				return State.EXPLODE
		State.EXPLODE:
			pass
		State.IDLE:
			if player:
				return State.CHASE
		State.WANDER:
			if (follow_point(wander_point)):
				return State.IDLE
			
	return state

# Takes in an old and new state and performs the exit and enter for the old and new state respectively. Returns new_state
func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	
	# State exit code
	match current_state:
		State.SPAWN:
			pass
		State.CHASE:
			navigation_agent.avoidance_enabled = false
			if new_state != State.EXPLODE:
				animation_reset()
		State.EXPLODE:
			animation_reset()
		State.IDLE:
			idle_timer.stop()
			animation_reset()
		State.WANDER:
			navigation_agent.avoidance_enabled = false
			animation_reset()
			
	#print(State.find_key(current_state) + " -> " + State.find_key(new_state)) Debug state print statement
	# State enter code
	match new_state:
		State.SPAWN:
			$Sprite2D.modulate = Color.TRANSPARENT
			anim_player.play("spawn")
		State.CHASE:
			navigation_agent.avoidance_enabled = true
			anim_player.play("chase")
		State.EXPLODE:
			anim_player.play("explode")
		State.IDLE:
			idle_timer.start(randf_range(min_idle_time, max_idle_time))
			anim_player.play("idle")
		State.WANDER:
			wander_point = get_random_wander_point()
			navigation_agent.avoidance_enabled = true
			wander_timer.start(max_wander_time)
			anim_player.play("wander")
		
	current_state = new_state


# Explode and then delete enemy
func explode() -> void:
	# Mold splatting
	for i in min_mold_per_explosion:
		var rand_pos := get_random_position_in_circle(global_position, explosion_radius)
		while(is_mold(rand_pos)):
			rand_pos = get_random_position_in_circle(global_position, explosion_radius)
		
		place_mold(get_random_position_in_circle(global_position, explosion_radius))
		
	# Player damage
	if (player and global_position.distance_squared_to(player.global_position) <= explosion_radius ** 2):
		player.take_damage(base_damage)
	
	# Removing self
	queue_free()


func animation_reset() -> void:
	$Sprite2D.modulate = Color.WHITE
	$Sprite2D.rotation = 0
	$Sprite2D.scale = Vector2.ONE * 0.2


func get_random_wander_point() -> Vector2:
	var distance := max_wander_dist * sqrt(randf_range(min_wander_dist / max_wander_dist, 1)) # Sqrt for equal distribution
	var direction := Vector2.RIGHT.rotated(randf_range(0, 2 * PI))

	return global_position + direction * distance


func _on_idle_timeout() -> void:
	if (current_state == State.IDLE):
		change_state(State.WANDER)


func _on_wander_timeout() -> void:
	if (current_state == State.WANDER):
		change_state(State.IDLE)


func get_random_position_in_circle(center: Vector2, radius: float) -> Vector2:
	var angle := randf_range(-PI, PI)
	var direction := Vector2(cos(angle), sin(angle))
	var distance := radius * randf() # This will cause points to be closer to center generally
	
	return center + distance * direction
