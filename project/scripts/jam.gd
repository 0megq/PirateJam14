class_name Jam extends Area2D

# Explanation for how the jam projectile collision works:
# Every time the collide and damge timer times out, we call the collide_and_damage() function that will damage enemies and update the hitbox's collision polygon. We give the collide and damage a length to check, this way it is in line with the movement of the particles. Every time the collide and damage is called we increment the length by COLLISION_LENGTH_PER_STEP until we have incremented DAMAGE_MAX_STEPS. Each step increases the current_damage_step integer by one.

# Damage
# The total damage variable is the damage the jam would do if the entire projectile hit one enemy. the damage_per_touch is used by the damage_enemy function to damage an enemy every time the collide and damage function collides with an enemy. This is a little complicated. Ask Nick for explanation on this part.

const PRECISION: float = 20
const COLLISION_LENGTH_PER_STEP: float = 20.0
const DAMAGE_MAX_STEPS: int = 6

@export var angle: float

# This is to be set by the script that instantiates the jam
var total_damage: float = 0.0 # this is the damage it would do if the enemy got hit by all the projectiles
var damage_per_touch: float = 0.0

var current_collision_length: float = 0.0
var current_damage_step: int = 0

var collided_rotations: Dictionary


@onready var angle_rad: float = deg_to_rad(angle)
@onready var angle_slice: float = angle_rad / PRECISION
@onready var enemy_cast: RayCast2D = $EnemyCast
@onready var particle_stop_timer: Timer = $ParticleStopTimer
@onready var particle_splat_timer: Timer = $ParticleSplatTimer
@onready var particle_decay_timer: Timer = $ParticleDecayTimer
@onready var collide_and_damage_timer: Timer = $CollideAndDamageTimer
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D


func _ready() -> void:
	# Start particles and setup properties
	particles.restart()
	z_index = 1
	damage_per_touch = total_damage / PRECISION
	
	# Conenct timer signals
	collide_and_damage_timer.timeout.connect(_on_collide_and_damage_timer_timeout)
	particle_stop_timer.timeout.connect(_on_particle_stop_timer_timeout)
	particle_decay_timer.timeout.connect(_on_particle_decay_timer_timeout)
	particle_splat_timer.timeout.connect(_on_particle_splat_timer_timeout)


# This does everything, but it is a little complicated. Ask nick if you need to use this function
func collide_and_damage(length: float) -> void:
	var points: PackedVector2Array = [Vector2.ZERO]
	
	for i in PRECISION + 1:
		var current_angle = i * angle_slice - angle_rad / 2
		
		enemy_cast.target_position = Vector2.RIGHT.rotated(current_angle) * length
		enemy_cast.force_raycast_update()
		var point: Vector2
		if collided_rotations.has(current_angle):
			point = collided_rotations[current_angle]
		elif enemy_cast.is_colliding():
			point = to_local(enemy_cast.get_collision_point())
			collided_rotations[current_angle] = point
			var collider := enemy_cast.get_collider()
			if collider.is_in_group("enemy") && collider.current_health > 0:
				damage_enemy(collider)
		else:
			point = enemy_cast.target_position
		points.append(point)
		
	collision_polygon.polygon = points


func _on_particle_splat_timer_timeout() -> void:
	z_index = -1


func _on_particle_decay_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(particles, "modulate", Color.TRANSPARENT, 1)
	place_jam_tiles()
	await tween.finished
	queue_free()


func _on_particle_stop_timer_timeout() -> void:
	particles.process_mode = PROCESS_MODE_DISABLED


func _on_collide_and_damage_timer_timeout() -> void:
	current_damage_step += 1
	if current_damage_step > DAMAGE_MAX_STEPS:
		collide_and_damage_timer.stop()
		return
	
	current_collision_length += COLLISION_LENGTH_PER_STEP
	collide_and_damage(current_collision_length)


func damage_enemy(enemy: Node2D) -> void:
	if enemy is EnemyBase:
		enemy.take_damage(damage_per_touch, true)
	else:
		enemy.take_damage(damage_per_touch)


func place_jam_tiles() -> void:
	var bounding_box := get_polygon_bounding_box(collision_polygon.polygon)
	var tile_size := Global.tile_map.tile_set.tile_size
	print(bounding_box)
	

# Returns a rectangle which outlines the entire collision polygon
func get_polygon_bounding_box(polygon: PackedVector2Array) -> Rect2:
	var minv: Vector2
	var maxv: Vector2
	for vertex in polygon:
		vertex = vertex.rotated(rotation)
		vertex += position
		if minv != null: # This has to be explicit. just doing minv will result in Vector2.ZERO being considered as false which is bad
			minv = Vector2(min(minv.x, vertex.x), min(minv.y, vertex.y))
		else:
			minv = vertex
		if maxv != null:
			maxv = Vector2(max(maxv.x, vertex.x), max(maxv.y, vertex.y))
		else: 
			maxv = vertex
	visualize_bounding_box_global(minv, maxv)
	var bounding_box = Rect2(minv, maxv - minv)
	return bounding_box


func visualize_bounding_box_global(minv: Vector2, maxv: Vector2) -> void:
	var new_line = Line2D.new()
	new_line.add_point(minv)
	new_line.add_point(Vector2(maxv.x, minv.y))
	new_line.add_point(maxv)
	new_line.add_point(Vector2(minv.x, maxv.y))
	new_line.add_point(minv)
	new_line.width = 1
	get_parent().add_child(new_line)
	
