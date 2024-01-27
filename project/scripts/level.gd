class_name Level extends Node2D

signal quit_level
signal retry_level
signal next_level

# How much does a single player life count in game score
const score_per_player_life: int = 7

# Bronze -> Gold
const score_per_medal: Array[int] = [50, 80, 100]

var enemies_left: int = 0

@onready var enemy_container: Node2D = $EnemyContainer
@onready var player: Player = $Player
@onready var tilemap: Map = $TileMap
@onready var ui: CanvasLayer = $UI


func _ready() -> void:
	enemies_left = enemy_container.get_child_count()
	enemy_container.child_entered_tree.connect(_on_enemy_added)
	enemy_container.child_exiting_tree.connect(_on_enemy_removed)
	player.died.connect(_on_player_died)


func _process(delta: float) -> void:
	update_enemy_cursor()


func update_enemy_cursor() -> void:
	var enemy_pos := get_closest_enemy_position()
	if enemy_pos < Vector2.INF:
		var screen_center := player.camera.get_screen_center_position()
		var enemy_screen_pos := enemy_pos - screen_center
		$UI.update_enemy_cursor(enemy_screen_pos)


# Get cloest enemy position to player. If there is outpost, outpost takes precedence even if outpost is farther than an enemy.
func get_closest_enemy_position() -> Vector2:
	if enemies_left <= 0:
		return Vector2.INF
	var is_outpost: bool = false
	var closest_position: Vector2
	var closest_distance_squared: float = INF
	for enemy in enemy_container.get_children():
		var distance_squared := player.position.distance_squared_to(enemy.position)
		if !is_outpost && enemy is EnemyOutpost: # Checks for the first outpost and stops once found
			is_outpost = true
			closest_distance_squared = distance_squared
			closest_position = enemy.position
		elif is_outpost && !(enemy is EnemyOutpost): # If outpost is already found and the enemy is not outpost skip
			continue
		elif distance_squared < closest_distance_squared:
			closest_distance_squared = distance_squared
			closest_position = enemy.position
		
	return closest_position


func _on_enemy_added(_node: Node) -> void:
	enemies_left += 1


func _on_enemy_removed(_node: Node) -> void:
	enemies_left -= 1
	if enemies_left <= 0:
		end_game()


func _on_player_died() -> void:
	lose_game()


func lose_game() -> void:
	ui.lose()


func end_game() -> void:
	tilemap.stop_spread()
	ui.game_over(get_score(), score_per_medal, player.current_lives, player.max_lives, score_per_player_life, tilemap.get_mold_percentage())
	

# Returns a score out of 100
func get_score() -> int:
	return player.current_lives * score_per_player_life + (1 - tilemap.get_mold_percentage()) * 100


func _on_ui_next_level() -> void:
	
	next_level.emit()


func _on_ui_quit_level() -> void:
	quit_level.emit()


func _on_ui_retry_level() -> void:
	retry_level.emit()
