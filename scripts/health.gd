extends Node
class_name Health

@export var max_health = 100

signal health_changed(amt)
signal killed
signal set_ui

var current_health = 0

func _ready():
	current_health = max_health

func take_damage(dmg):
	current_health -= dmg
	
	if(current_health <= 0):
		killed.emit()
	else:
		health_changed.emit(dmg)
