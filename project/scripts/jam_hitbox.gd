extends Area2D

const precision: float = 20

@export var angle: float

var collided_rotations: Dictionary

var jam: Jam

@onready var angle_rad: float = deg_to_rad(angle)
@onready var angle_slice: float = angle_rad / precision
@onready var enemy_cast: RayCast2D = $EnemyCast


# This does everything, but it is a little complicated. Ask nick if you need to use this function
func collide_and_damage(length: int) -> void:
	var points: PackedVector2Array = [Vector2.ZERO]
	
	for i in precision + 1:
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
				jam.damage_enemy(collider)
		else:
			point = enemy_cast.target_position
		points.append(point)
		
	$CollisionPolygon2D.polygon = points
