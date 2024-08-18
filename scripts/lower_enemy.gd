extends CharacterBody2D
class_name LowEnemy

@onready var timer = $Timer
@onready var proj_position = $Proj_Position_Holder/Proj_Position
@onready var proj_position_holder = $Proj_Position_Holder
@onready var health = $health
@onready var dash_timer = $Dash_Timer
@onready var collider = $CollisionPolygon2D
@onready var hurtbox_collider = $Hurtbox/CollisionShape2D
@onready var hitbox_collider = $Hitbox/CollisionShape2D

@export var attack_range = 300.0
@export var time_to_attack = .25
@export var dash_speed = 400.0

var proj = preload("res://scenes/prefabs/projectile.tscn")

const SPEED = 200.0
const DASH_SPEED_MULT = 4

var player: Player
var is_dashing = false
var dash_direction: Vector2
var dash_time = .15
var is_spawned = false

func _physics_process(delta):
	if(!player or !is_spawned):
		return
	
	proj_position_holder.look_at(player.position) #Need to add an extra 90 deg rotation
	proj_position_holder.rotate(deg_to_rad(90))

	if(!is_dashing and position.distance_to(player.position) > attack_range):
		velocity = position.direction_to(player.position) * SPEED
	elif(is_dashing):
		velocity = dash_direction * SPEED * DASH_SPEED_MULT
	else:
		velocity = Vector2.ZERO
		attempt_dash()
	
	move_and_slide()

func spawn_enemy():
	hitbox_collider.disabled = false
	hurtbox_collider.disabled = false
	collider.disabled = false
	player = get_tree().root.get_child(0).get_node("player")
	is_spawned = true

func attempt_dash():
	if(timer.time_left > 0):
		return
	timer.start(time_to_attack)

func _on_timer_timeout():
	if(!player):
		return
	is_dashing = true
	dash_direction = position.direction_to(player.position)
	collider.disabled = true
	hurtbox_collider.disabled = true
	dash_timer.start(dash_time)


func _on_health_health_changed(amt):
	pass


func _on_health_killed():
	queue_free()
	#TODO: Make death animation


func _on_hurtbox_area_entered(hitbox):
	health.take_damage(hitbox.damage)
	hitbox.did_damage.emit()


func _on_dash_timer_timeout():
	is_dashing = false
	collider.disabled = false
	hurtbox_collider.disabled = false
