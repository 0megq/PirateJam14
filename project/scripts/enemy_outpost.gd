extends Area2D

var enemy_scenes: Dictionary = {
	EnemyBase.Type.KAMIKAZE : preload("res://scenes/enemy_kamikaze.tscn")
}

@export var spawn_interval: float
@export var enemy_types: Array[EnemyBase.Type]
@export var health: int

@onready var spawn_timer: Timer = $SpawnTimer


func _ready() -> void:
	enemy_scenes.make_read_only()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	_on_spawn_timer_timeout.call_deferred()
	start_spawner()


func start_spawner() -> void:
	spawn_timer.start(spawn_interval)
	
		
func stop_spawner() -> void:
	spawn_timer.stop()


func _on_spawn_timer_timeout() -> void:
	spawn_enemy(enemy_types.pick_random())


func spawn_enemy(type: EnemyBase.Type) -> void:
	var enemy_scene: PackedScene = enemy_scenes[type]
	var enemy: EnemyBase = enemy_scene.instantiate()
	enemy.global_position = global_position
	get_parent().add_child(enemy)


func take_damage(dmg: int) -> void:
	health -= dmg
	if health < 0:
		print(str(self) + " died D:")
		queue_free()
