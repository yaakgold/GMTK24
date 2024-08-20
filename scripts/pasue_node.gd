extends Node2D

@onready var vsp = $"../VideoStreamPlayer"
@onready var audio = $"../VideoStreamPlayer/AudioStreamPlayer2D"

func spawn_enemy():
	vsp.play()
	await get_tree().create_timer(7.25).timeout
	audio.play()
	await get_tree().create_timer(.15).timeout
	queue_free()
