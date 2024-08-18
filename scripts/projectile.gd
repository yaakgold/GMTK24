extends Hitbox
class_name Projectile

@onready var timer = $Timer
@onready var gfx = $CollisionShape2D/Sprite2D

@export var kill_time = 1.0

var speed = 0.0
var direction

func _ready():
	timer.start(kill_time)

func _physics_process(delta):
	if(speed > 0):
		global_position += speed * direction * delta

func fire(_speed, target_pos, color, is_player):
	speed = _speed
	direction = position.direction_to(target_pos)
	gfx.modulate = color
	
	if(is_player):
		var rng = RandomNumberGenerator.new()
		damage = 10 + rng.randi_range(-4, 5)
	else:
		damage = 1
	
	set_collision_layer_value((2 if is_player else 3), true)
	set_collision_mask_value((2 if is_player else 3), true)

func _on_timer_timeout():
	queue_free()

func _on_did_damage():
	queue_free()
