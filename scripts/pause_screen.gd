extends CanvasLayer

func _process(delta):
	if(Input.is_action_just_pressed("exit")):
		_on_btn_continue_pressed()

func _on_btn_continue_pressed():
	get_tree().paused = false
	queue_free()

func _on_btn_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
