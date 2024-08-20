extends Node2D

var win_screen = preload("res://scenes/UI/win.tscn")

@onready var audio = $AudioStreamPlayer2D

func _ready():
	var t: GameTimerScript = get_tree().root.get_node("GameTimer")
	if(t):
		t.started = false
	await get_tree().create_timer(11).timeout
	var ws = win_screen.instantiate()
	add_child(ws)	
