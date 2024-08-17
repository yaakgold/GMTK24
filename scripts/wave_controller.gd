extends Node

var section_number: int = 0
var wave_number: int = 0

const WAVE_COUNTS = [2]

func _ready():
	await get_tree().create_timer(1.5).timeout
	start_next_wave()

func _process(delta):
	if(get_tree().get_node_count_in_group(get_current_wave()) == 0):
		start_next_wave()

func get_current_wave():
	return "wave_" + str(section_number) + "_" + str(wave_number)

func start_next_wave():
	if(WAVE_COUNTS[section_number] == wave_number):
		next_section()
	
	wave_number += 1
	
	get_tree().call_group(get_current_wave(), "spawn_enemy")

func next_section():
	section_number += 1
	wave_number = 0
