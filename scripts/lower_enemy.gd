extends CharacterBody2D
class_name LowEnemy

@onready var timer = $Timer
@onready var proj_position = $Proj_Position_Holder/Proj_Position
@onready var proj_position_holder = $Proj_Position_Holder
@onready var health = $health

@export var attack_range = 300.0
@export var time_to_attack = 1.0
@export var dash_speed = 400.0

var proj = preload("res://scenes/prefabs/projectile.tscn")

const SPEED = 200.0

var player: Player

func _ready():
	player = get_node("../player")

func _physics_process(delta):
	if(!player):
		return
	
	proj_position_holder.look_at(player.position) #Need to add an extra 90 deg rotation
	proj_position_holder.rotate(deg_to_rad(90))
	#print(position.distance_to(player.position))
	if(position.distance_to(player.position) > attack_range):
		velocity = position.direction_to(player.position) * SPEED
		pass
	else:
		velocity = Vector2.ZERO
		attempt_dash()
		pass
	
	move_and_slide()

func attempt_dash():
	if(timer.time_left > 0):
		return
	print("Timer started")
	timer.start(time_to_attack)

func _on_timer_timeout():
	#TODO: Add a current velocity to use in the _physics_process look instead of Vec2.ZERO
	velocity = position.direction_to(player.position) * dash_speed
	
	move_and_slide()


func _on_health_health_changed(amt):
	print(amt)


func _on_health_killed():
	queue_free()
	#TODO: Make death animation
