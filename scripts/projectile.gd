extends Hitbox
class_name Projectile

@onready var timer = $Timer

@export var kill_time = 1.0

var speed = 0.0
var direction

func _ready():
	timer.start(kill_time)

func _physics_process(delta):
	if(speed > 0):
		global_position += speed * direction * delta

func fire(_speed, target_pos):
	speed = _speed
	direction = position.direction_to(target_pos)

func _on_timer_timeout():
	queue_free()

func _on_did_damage():
	queue_free()
