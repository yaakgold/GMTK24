extends CanvasLayer

@onready var sub_title = $PanelContainer/MarginContainer/Rows/VBoxContainer/SubTitle

func _ready():
	var t: GameTimerScript = get_tree().root.get_node("GameTimer")
	sub_title.text = "OK\n\nYou successfully posted your game! Congrats\nTime Taken: " + convert_time(t.time)

func convert_time(seconds):
	return str(floor(seconds)) + " seconds"

func _on_btn_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")


func _on_btn_quit_pressed():
	get_tree().quit()
