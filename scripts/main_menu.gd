extends CanvasLayer

func _ready():
	var t: GameTimerScript = get_tree().root.get_node("GameTimer")
	if(t):
		t.started = false

func _on_btn_execute_pressed():
	var t: GameTimerScript = get_tree().root.get_node("GameTimer")
	if(t):
		t.started = true
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_btn_quit_pressed():
	get_tree().quit()
