extends Node

@onready var cam = $"../Camera2D"
@onready var bg = $"../WORLD/BG"

var section_number: int = 0
var wave_number: int = 0
var wave_active = false
var cam_zoom = false
var move_bg = false

const ZOOM_SPEED = 2
const MOVE_SPEED = 2
const WAVE_COUNTS = [2, 0]
const SECTION_BG_Y_POS = [0.0, 0.0]

func _ready():
	await get_tree().create_timer(1.5).timeout
	start_next_wave()

func _process(delta):
	if(wave_active and get_tree().get_node_count_in_group(get_current_wave()) == 0):
		start_next_wave()
	
	if(cam_zoom):
		cam.zoom.x = lerp(cam.zoom.x, 1.0, delta * ZOOM_SPEED)
		cam.zoom.y = lerp(cam.zoom.y, 1.0, delta * ZOOM_SPEED)
		
		if(cam.zoom.x <= 1.0005):
			cam_zoom = false
			cam.zoom.x = 1
			cam.zoom.y = 1
			move_bg = true
	
	if(move_bg):
		bg.position.y = lerp(bg.position.y, SECTION_BG_Y_POS[section_number], delta * MOVE_SPEED)
		
		if(bg.position.y - SECTION_BG_Y_POS[section_number] < .05):
			bg.position.y = SECTION_BG_Y_POS[section_number]
			move_bg = false

func get_current_wave():
	return "wave_" + str(section_number) + "_" + str(wave_number)

func start_next_wave():
	#TODO: Create a timer between the waves?
	wave_active = false
	if(WAVE_COUNTS[section_number] == wave_number):
		next_section()
	
	wave_number += 1
	wave_active = true
	get_tree().call_group(get_current_wave(), "spawn_enemy")

func next_section():
	if(section_number < WAVE_COUNTS.size() - 1):
		section_number += 1
		wave_number = 0
		cam_zoom = true
