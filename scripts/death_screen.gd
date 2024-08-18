extends CanvasLayer

func _on_btn_restart_pressed():
	#TODO: Change this to the Main Menu
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")


func _on_btn_quit_pressed():
	get_tree().quit()
