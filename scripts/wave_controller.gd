extends Node

@onready var cam = $"../Camera2D"
@onready var bg = $"../WORLD/BG"

@onready var boundry_north = $"../Camera2D/Boundry_North"
@onready var boundry_south = $"../Camera2D/Boundry_South"
@onready var boundry_west = $"../Camera2D/Boundry_West"
@onready var boundry_east = $"../Camera2D/Boundry_East"

var section_number: int = 0
var wave_number: int = 0
var wave_active = false
var cam_zoom = false
var move_bg = false

const ZOOM_SPEED = 2
const MOVE_SPEED = 2
const WAVE_COUNTS = [2, 3, 1, 1]
const SECTION_CAM_Y_POS = [0.0, -480.0, -1532.0, -27000.0]

func _ready():
	#await get_tree().create_timer(1.5).timeout
	#start_next_wave()
	
	#TODO: This is just for testing the boss
	cam_zoom = true
	section_number = 1
	wave_number = 3

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
		cam.position.y = lerp(cam.position.y, SECTION_CAM_Y_POS[section_number], delta * MOVE_SPEED)
		if(abs(cam.position.y - SECTION_CAM_Y_POS[section_number]) < .15):
			cam.position.y = SECTION_CAM_Y_POS[section_number]
			move_bg = false
			
			boundry_east.position.x = 956.0
			boundry_west.position.x = -956.0
			boundry_south.position.y = 533.0
			boundry_north.position.y = -533.0
			start_next_wave()

func get_current_wave():
	return "wave_" + str(section_number) + "_" + str(wave_number)

func start_next_wave():
	wave_active = false
	if(WAVE_COUNTS[section_number] == wave_number):
		next_section()
		return
	
	wave_number += 1
	wave_active = true
	
	await get_tree().create_timer(3).timeout
	get_tree().call_group(get_current_wave(), "spawn_enemy")

func next_section():
	if(section_number < WAVE_COUNTS.size() - 1):
		section_number += 1
		wave_number = 0
		cam_zoom = true
