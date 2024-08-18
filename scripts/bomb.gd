extends Area2D
class_name Bomb

@onready var label = $Label
@onready var collision = $CollisionShape2D

var time_left = 3.0

func _process(delta):
	time_left -= delta
	label.text = str(ceil(time_left))
	scale = lerp(scale, Vector2(1.25, 1.25), delta)
	
	if(time_left <= 0):
		explode()
	
func explode():
	for b in get_overlapping_bodies():
		if(b is LowEnemy or b is CapEnemy):
			b.health.take_damage(100)
	queue_free()
