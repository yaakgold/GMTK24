extends TextureProgressBar

@export var health: Health
@onready var animation_player = $"AnimationPlayer"


func _ready():
	health.set_ui.connect(start_anim)
	health.health_changed.connect(update)
	
	if(health.get_parent() is Player):
		health.set_ui.emit()

func update(val):
	value = health.current_health

func start_anim():
	animation_player.play("start")
