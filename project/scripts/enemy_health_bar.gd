extends ProgressBar

## Time it takes for the bar to go from fully transparent to fully non-transparent
@export var fade_in_time: float
## Time it takes for the bar to go from fully non-transparent to fully transparent
@export var fade_out_time: float
## Time the bar is fully displayed after fading in and before fading out
@export var display_time: float
@export var enemy: Node2D

## If true the health bar will be shown at all times
@export var persistent: bool = false

## Used to track if the current health change is the first change done to this health bar. Used to hide health bar of enemy when first spawned
var first_change: bool = true

func _ready() -> void:
	if !persistent:
		modulate = Color.TRANSPARENT
	enemy.health_changed.connect(_on_enemy_health_changed)


func _on_enemy_health_changed(current_health: float, max_health: int) -> void:
	value = current_health
	max_value = max_health
	
	if first_change:
		first_change = false
		return
	
	if !persistent:	
		await fade_in()
		
		$BarDisplayTimer.start(display_time)
		await $BarDisplayTimer.timeout
		fade_out()

	
func fade_in() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, fade_in_time)
	await tween.finished
	
	
func fade_out() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_out_time)
