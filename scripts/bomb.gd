extends Hitbox
class_name Bomb

@onready var label = $Label
@onready var collision = $CollisionShape2D
@onready var sprite = $CollisionShape2D/Sprite2D
@onready var particles = $CPUParticles2D
@onready var audio = $AudioStreamPlayer2D

var time_left = 3.0
var is_player = false

const THROW_SPEED = 1

func _process(delta):
	time_left -= delta
	label.text = str(ceil(time_left))
	scale = lerp(scale, Vector2(1.25, 1.25), delta)
	
	if(time_left <= 0):
		explode()

func explode():
	if is_player:
		audio.play()
	
	particles.emitting = true
	
	collision.disabled = true
	sprite.visible = false
	label.visible = false
	
	for b in get_overlapping_bodies():
		if(is_player and (b is LowEnemy or b is CapEnemy)):
			b.health.take_damage(100)
		if(!is_player and b is Player):
			b.health.take_damage(7)
			
	await get_tree().create_timer(1).timeout
	queue_free()
