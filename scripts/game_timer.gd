extends Node2D
class_name GameTimerScript

var started = false
var time = 0.0

func _process(delta):
	if(started):
		time += delta
