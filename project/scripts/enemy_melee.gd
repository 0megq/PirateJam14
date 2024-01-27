class_name EnemyMelee extends EnemyBase


enum State {
	SPAWN,
	CHASE,
	ATTACK,
	IDLE,
	WANDER,
	NONE,
}

const MIN_WANDER_DIST: float = 40.0
const MAX_WANDER_DIST: float = 100.0

const MIN_IDLE_TIME: float = 1.0
const MAX_IDLE_TIME: float = 6.0

const MAX_WANDER_TIME: float = 5.0

@export var start_state: State

var current_state: State = State.NONE
var wander_point: Vector2

@onready var attack_radius: float = $AttackRadius.shape.radius
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var idle_timer: Timer = $IdleTimer
@onready var wander_timer: Timer = $WanderTimer
@onready var attack_hitbox_x: int = abs($AttackHitbox/CollisionShape2D.position.x)

func _ready() -> void:
	super()
	type = Type.MELEE
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
		State.ATTACK:
			if player:
				change_state(State.CHASE)
			else:
				change_state(State.IDLE)
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
			elif is_player_in_radius(attack_radius):
				return State.ATTACK
			else:
				follow_point(player.global_position)
			look_player()
		State.ATTACK:
			if !player:
				return State.IDLE
		State.IDLE:
			if player:
				return State.CHASE
		State.WANDER:
			look_velocity()
			if (follow_point(wander_point)):
				return State.IDLE
			
	return state


func look_player() -> void:
	if player:
		var direction := global_position.direction_to(player.global_position)
		$Sprite2D.flip_h = direction.x > 0
		if $Sprite2D.flip_h:
			$AttackHitbox/CollisionShape2D.position.x = attack_hitbox_x
		else:
			$AttackHitbox/CollisionShape2D.position.x = -attack_hitbox_x
		
func look_velocity() -> void:
	$Sprite2D.flip_h = velocity.x > 0
	if $Sprite2D.flip_h:
		$AttackHitbox/CollisionShape2D.position.x = attack_hitbox_x
	else:
		$AttackHitbox/CollisionShape2D.position.x = -attack_hitbox_x


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
			animation_reset()
		State.ATTACK:
			pass
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
		State.ATTACK:
			anim_player.play("attack")
		State.IDLE:
			idle_timer.start(randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME))
			anim_player.play("idle")
		State.WANDER:
			wander_point = get_random_wander_point()
			navigation_agent.avoidance_enabled = true
			wander_timer.start(MAX_WANDER_TIME)
			anim_player.play("wander")
		
	current_state = new_state


func animation_reset() -> void:
	$Sprite2D.modulate = Color.WHITE
	$Sprite2D.rotation = 0
	$Sprite2D.scale = Vector2.ONE


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if player == body:
		player.take_damage(base_damage)


func get_random_wander_point() -> Vector2:
	var distance := MAX_WANDER_DIST * sqrt(randf_range(MIN_WANDER_DIST / MAX_WANDER_DIST, 1)) # Sqrt for equal distribution
	var direction := Vector2.RIGHT.rotated(randf_range(0, 2 * PI))

	return global_position + direction * distance


func _on_idle_timeout() -> void:
	if (current_state == State.IDLE):
		change_state(State.WANDER)


func _on_wander_timeout() -> void:
	if (current_state == State.WANDER):
		change_state(State.IDLE)


func die() -> void:
	# Placeholder
	print("%s died" % self)
	queue_free()


func is_player_in_radius(radius: float) -> bool:
	return global_position.distance_squared_to(player.global_position) <= radius ** 2
