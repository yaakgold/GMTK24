extends Node2D
class_name GameController

signal player_death(player)

var death_screen = preload("res://scenes/UI/death_screen.tscn")

func _on_player_death(player):
	player.queue_free()
	
	var ds = death_screen.instantiate()
	get_tree().root.add_child(ds)
	
