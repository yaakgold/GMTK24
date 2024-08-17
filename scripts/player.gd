extends CharacterBody2D
class_name Player

@onready var proj_position = $Proj_Position_Holder/Proj_Position
@onready var proj_position_holder = $Proj_Position_Holder
@onready var health: Health = $health
@onready var dash_timer = $Dash_Timer
@onready var collider = $CollisionPolygon2D
@onready var hurtbox_collider = $Hurtbox/CollisionShape2D

@export var dash_time = .15

const SPEED = 300.0
const SLOW_DOWN_SPEED = 2.0
const DASH_SPEED_MULT = 3

var proj = preload("res://scenes/prefabs/projectile.tscn")

var is_dashing = false

func _physics_process(delta):
	#TODO: Move this somewhere that makes more sense
	if(Input.is_action_pressed("exit")):
		get_tree().quit()
	
	
	update_movement(delta)
	aim_and_fire()
	

func update_movement(delta):
	if(!is_dashing && Input.is_action_just_pressed("dash")):
		is_dashing = true
		collider.disabled = true
		hurtbox_collider.disabled = true
		dash_timer.start(dash_time)
	
	# Get the input direction and handle the movement/deceleration.
	var directionx = Input.get_axis("left", "right")
	if directionx:
		velocity.x = directionx * SPEED * (DASH_SPEED_MULT if is_dashing else 1)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * SLOW_DOWN_SPEED * delta)
		
	var directiony = Input.get_axis("up", "down")
	if directiony:
		velocity.y = directiony * SPEED * (DASH_SPEED_MULT if is_dashing else 1)
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED * SLOW_DOWN_SPEED  * delta)
	
	move_and_slide()
	
func aim_and_fire():
	#Aim
	proj_position_holder.look_at(get_global_mouse_position()) #Need to add an extra 90 deg rotation
	proj_position_holder.rotate(deg_to_rad(90))
	
	#Fire
	if(Input.is_action_just_pressed("fire")):
		var p: Projectile = proj.instantiate()
		p.position = proj_position.global_position
		get_tree().root.add_child(p)
		p.fire(400, get_global_mouse_position())

func _on_health_health_changed(amt):
	if(amt > 0): #This mean damage was taken
		print("Ouch: " + str(amt))
	else:
		print("Yummy: " + str(amt))

func _on_health_killed():
	queue_free()
	#TODO: Do something here on death

func _on_dash_timer_timeout():
	is_dashing = false
	collider.disabled = false
	hurtbox_collider.disabled = false

func _on_hurtbox_area_entered(hitbox):
	health.take_damage(hitbox.damage)
