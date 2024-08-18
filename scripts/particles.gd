extends Node2D

@onready var particles = $CPUParticles2D

func _ready():
	print(global_position)
	particles.emitting = true
	await get_tree().create_timer(1).timeout
	queue_free()
