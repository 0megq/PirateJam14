extends BoxContainer

@export var player: Player
@onready var progress_bar := $ProgressBar
@onready var value_label := $ValueLabel

func _ready():
	#Health
	player.health_changed.connect(update)
	update()
	
func update():
	#Health
	progress_bar.value = player.current_health * 100 / player.max_health
	value_label.text = str(player.current_health) + "/" + str(player.max_health)
