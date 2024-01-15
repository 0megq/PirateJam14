class_name EnemyKamikaze extends EnemyBase


enum State {
	SPAWN,
	CHASE,
	EXPLODE,
	IDLE,
	NONE,
}

const max_distance_to_explode: float = 60

@export var start_state: State

var current_state: State = State.NONE

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var explosion_area: Area2D = $ExplosionArea

func _ready() -> void:
	super()
	type = Type.KAMIKAZE
	anim_player.animation_finished.connect(_on_animation_finished)
	change_state(start_state)
	

func _physics_process(delta: float) -> void:
	change_state(update_state(current_state))


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "RESET":
		return
		
	match current_state:
		State.SPAWN:
			if player:
				change_state(State.CHASE)
			else:
				change_state(State.IDLE)
		State.CHASE:
			pass
		State.EXPLODE:
			explode()
		State.IDLE:
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
		State.EXPLODE:
			animation_reset()
		State.IDLE:
			animation_reset()
			
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
			anim_player.play("idle")
		
	current_state = new_state


# Explode and then delete enemy
func explode() -> void:
	# Splatting mold needs to happen here
	if (player and explosion_area.overlaps_body(player)):
		player.take_damage(base_damage)
	queue_free()


func animation_reset() -> void:
	$Sprite2D.modulate = Color.WHITE
	$Sprite2D.rotation = 0
	$Sprite2D.scale = Vector2.ONE * 0.2
