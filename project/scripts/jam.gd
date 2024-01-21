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
		enemy.take_damage(damage_per_touch, global_position, true)
	else:
		enemy.take_damage(damage_per_touch)



func get_tilemap_aligned_bounding_box(polygon: PackedVector2Array, tile_size: Vector2i) -> Rect2i:
	# Getting bounding box of polygon. Polygon should be in global coords
	var bounding_box := get_polygon_bounding_box(polygon)
	
	
	var tile_aligned_minv: Vector2i
	var tile_aligned_maxv: Vector2i

	# Snapping start to tile_size
	tile_aligned_minv.x = floori(bounding_box.position.x / tile_size.x) * tile_size.x
	tile_aligned_minv.y = floori(bounding_box.position.y / tile_size.y) * tile_size.y
	
	# Snapping end to tile_size
	tile_aligned_maxv.x = ceili(bounding_box.end.x / tile_size.x) * tile_size.x
	tile_aligned_maxv.y = ceili(bounding_box.end.y / tile_size.y) * tile_size.y
	
	return Rect2i(tile_aligned_minv, tile_aligned_maxv - tile_aligned_minv)


func place_jam_tiles() -> void:
	var tile_size := Global.tile_map.tile_set.tile_size
	var col_polygon_global := polygon_to_global(collision_polygon.polygon)
	var tile_aligned_bounding_box: Rect2i = get_tilemap_aligned_bounding_box(col_polygon_global, tile_size)
	
	for x in range(tile_aligned_bounding_box.position.x, tile_aligned_bounding_box.end.x, tile_size.x):
		for y in range(tile_aligned_bounding_box.position.y, tile_aligned_bounding_box.end.y, tile_size.y):
			if Geometry2D.is_point_in_polygon(Vector2(x + tile_size.x / 2, y + tile_size.y / 2), col_polygon_global):
				var tile_coord := Global.tile_map.local_to_map(Global.tile_map.to_local(Vector2(x, y)))
				Global.tile_map.set_cell(0, tile_coord, 0,  Global.tile_map.jam_terrain)
			
			

# Returns a rectangle which outlines the entire collision polygon
func get_polygon_bounding_box(polygon: PackedVector2Array) -> Rect2:
	var minv: Vector2
	var maxv: Vector2
	for vertex in polygon:
		if minv:
			minv = Vector2(min(minv.x, vertex.x), min(minv.y, vertex.y))
		else:
			minv = vertex
		if maxv:
			maxv = Vector2(max(maxv.x, vertex.x), max(maxv.y, vertex.y))
		else: 
			maxv = vertex
	var bounding_box = Rect2(minv, maxv - minv)
	return bounding_box
	
	
func polygon_to_global(polygon: PackedVector2Array) -> PackedVector2Array:	
	for i in polygon.size():
		polygon[i] = polygon[i].rotated(rotation) + global_position
	
	return polygon


#func visualize_bounding_box_global(minv: Vector2, maxv: Vector2) -> void:
	#var new_line = Line2D.new()
	#new_line.add_point(minv)
	#new_line.add_point(Vector2(maxv.x, minv.y))
	#new_line.add_point(maxv)
	#new_line.add_point(Vector2(minv.x, maxv.y))
	#new_line.add_point(minv)
	#new_line.width = 1
	#get_parent().add_child(new_line)


#func visualize_polygon_global(polygon: PackedVector2Array) -> void:
	#var new_polygon: Polygon2D = Polygon2D.new()
	#new_polygon.polygon = polygon
	#get_parent().add_child(new_polygon)


