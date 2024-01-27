class_name EnemyKamikaze extends EnemyBase


enum State {
	SPAWN,
	CHASE,
	CHARGE,
	EXPLODE,
	IDLE,
	WANDER,
	NONE,
}

const MIN_WANDER_DIST: float = 40.0
const MAX_WANDER_DIST: float = 100.0

const MIN_IDLE_TIME: float = 1.0
const MAX_IDLE_TIME: float = 6.0

const MAX_WANDER_TIME: float = 5.0

const MAX_MOLD_PLACE_ATTEMPTS: int = 10
const MOLD_PER_EXPLOSION: int = 15

@export var start_state: State

var current_state: State = State.NONE
var wander_point: Vector2

@onready var explosion_damage_radius: float = $ExplosionDamageRadius.shape.radius
@onready var explosion_confirm_radius: float = $ExplosionConfirmRadius.shape.radius
@onready var charge_radius: float = $ChargeRadius.shape.radius
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
		State.CHARGE:
			if is_player_in_radius(explosion_confirm_radius):
				change_state(State.EXPLODE)
			else:
				change_state(State.CHASE)
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
			elif is_player_in_radius(charge_radius):
				return State.CHARGE
			else:
				follow_point(player.global_position)
			look_player()
		State.CHARGE:
			if !player:
				return State.IDLE
			look_player()
		State.EXPLODE:
			pass
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
		
func look_velocity() -> void:
	$Sprite2D.flip_h = velocity.x > 0


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
		State.CHARGE:
			pass
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
		State.CHARGE:
			anim_player.play("charge")
		State.EXPLODE:
			anim_player.play("explode")
			$Explosion.play()
		State.IDLE:
			idle_timer.start(randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME))
			anim_player.play("idle")
		State.WANDER:
			wander_point = get_random_wander_point()
			navigation_agent.avoidance_enabled = true
			wander_timer.start(MAX_WANDER_TIME)
			anim_player.play("wander")
		
	current_state = new_state


# Explode and then delete enemy
func explode() -> void:
	# Mold splatting
	if Global.tile_map:
		for i in MOLD_PER_EXPLOSION:
			var rand_pos := get_random_position_in_circle(global_position, explosion_damage_radius)
			var attempts = 0
			while(Global.tile_map.is_type_mold_g(Global.tile_map.main_layer, rand_pos)):
				attempts += 1
				if attempts > MAX_MOLD_PLACE_ATTEMPTS:
					break
				rand_pos = get_random_position_in_circle(global_position, explosion_damage_radius)
			
			Global.tile_map.place_mold_g(Global.tile_map.main_layer, rand_pos)
		
	# Player damage
	if (player and is_player_in_radius(explosion_damage_radius)):
		player.take_damage(base_damage)
	
	# Removing self
	set_modulate(Color(0,0,0,0))
	await $Explosion.finished
	queue_free()


func animation_reset() -> void:
	$Sprite2D.modulate = Color.WHITE
	$Sprite2D.rotation = 0
	$Sprite2D.scale = Vector2.ONE


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


func get_random_position_in_circle(center: Vector2, radius: float) -> Vector2:
	var angle := randf_range(-PI, PI)
	var direction := Vector2(cos(angle), sin(angle))
	var distance := radius * randf() # This will cause points to be closer to center generally
	
	return center + distance * direction


func die() -> void:
	# Placeholder
	print("%s died" % self)
	set_modulate(Color(0,0,0,0))
	await $Hurt.finished
	queue_free()


func is_player_in_radius(radius: float) -> bool:
	return global_position.distance_squared_to(player.global_position) <= radius ** 2
