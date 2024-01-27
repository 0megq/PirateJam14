class_name EnemyOutpost extends Area2D

signal health_changed(current_health: float, max_health: int)

var enemy_scenes: Dictionary = {
	EnemyBase.Type.KAMIKAZE : preload("res://scenes/enemy_kamikaze.tscn"),
	EnemyBase.Type.MELEE : preload("res://scenes/enemy_melee.tscn"),
}

@export var spawn_interval: float
@export var hurt_time: float
@export var enemy_types: Array[EnemyBase.Type]
@export var max_health: int :
	set(value):
		max_health = value
		health_changed.emit(current_health, max_health)

var current_health: float :
	set(value):
		current_health = value
		health_changed.emit(current_health, max_health)
		
var is_hurt: bool = false

@onready var hurt_timer: Timer = $HurtTimer
@onready var spawn_timer: Timer = $SpawnTimer


func _ready() -> void:
	set_deferred("current_health", max_health)
	enemy_scenes.make_read_only()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	_on_spawn_timer_timeout.call_deferred()
	start_spawner()
	$AnimationPlayer.play("idle")


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


func take_damage(damage: float, is_jam: bool = false) -> void:
	if is_hurt && !is_jam:
		return
	current_health -= damage
	
	if current_health <= 0:
		print(str(self) + " died D:")
		queue_free()
	
	is_hurt = true
	hurt_timer.start(hurt_time)
	await hurt_timer.timeout
	is_hurt = false
