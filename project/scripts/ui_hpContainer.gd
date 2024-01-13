extends BoxContainer

@export var player: Player
@onready var healthBar := $healthBar
@onready var hpValueLabel := $hpValueLabel

func _ready():
	#Health
	player.healthChanged.connect(update)
	update()
	
	#Jam


func update():
	#Health
	healthBar.value = player.currentHealth * 100 / player.maxHealth
	hpValueLabel.text = str(player.currentHealth) + "/" + str(player.maxHealth)


func _on_player_health_changed() -> void:
	update()
