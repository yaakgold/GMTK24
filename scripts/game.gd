extends Node2D
class_name GameController

signal player_death(player)
signal player_beat_boss

@export var cam: Camera2D

var death_screen = preload("res://scenes/UI/death_screen.tscn")

func _process(delta):
	if(Input.is_action_just_pressed("exit")):
		#TODO: Change this to be a pause menu
		get_tree().quit()

func _on_player_death(player):
	player.queue_free()
	
	var ds = death_screen.instantiate()
	add_child(ds)
	
