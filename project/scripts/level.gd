class_name Level extends Node2D

# How much does a single player life count in game score
const score_per_player_life: int = 7

var enemies_left: int = 0

@onready var enemy_container: Node2D = $EnemyContainer
@onready var player: Player = $Player
@onready var tilemap: Map = $TileMap


func _ready() -> void:
	enemies_left = enemy_container.get_child_count()
	enemy_container.child_entered_tree.connect(_on_enemy_added)
	enemy_container.child_exiting_tree.connect(_on_enemy_removed)
	player.died.connect(_on_player_died)


func _on_enemy_added(_node: Node) -> void:
	enemies_left += 1


func _on_enemy_removed(_node: Node) -> void:
	enemies_left -= 1
	print(enemies_left)
	if enemies_left <= 0:
		end_game()


func _on_player_died() -> void:
	lose_game()


func lose_game() -> void:
	print("player lost all lives and died")

	
func end_game() -> void:
	print("game ending all enemies died")
	print("you got %s score" % get_score())
	

# Returns a score out of 100
func get_score() -> int:
	return player.current_lives * score_per_player_life + (1 - tilemap.get_mold_percentage()) * 100
