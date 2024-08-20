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
@onready var dash_audio = $Dash_Audio
@onready var hit_audio = $Hit_Audio

@export var attack_range = 200.0
@export var time_to_attack = .05
@export var dash_speed = 400.0

var proj = preload("res://scenes/prefabs/projectile.tscn")
var part = preload("res://scenes/prefabs/particles.tscn")

const SPEED = 275.0
const DASH_SPEED_MULT = 6

var player: Player
var is_dashing = false
var dash_direction: Vector2
var dash_time = .15
var is_spawned = false

func _physics_process(delta):
	if(!player or !is_spawned):
		return
	
	proj_position_holder.look_at(player.global_position) #Need to add an extra 90 deg rotation
	proj_position_holder.rotate(deg_to_rad(90))

	if(!is_dashing and global_position.distance_to(player.global_position) > attack_range):
		velocity = global_position.direction_to(player.global_position) * SPEED
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
	player = get_tree().root.get_child(2).get_node("player")
	is_spawned = true

func attempt_dash():
	if(timer.time_left > 0):
		return
	timer.start(time_to_attack)
	dash_audio.play()

func _on_timer_timeout():
	if(!player):
		return
	is_dashing = true
	dash_direction = global_position.direction_to(player.global_position)
	collider.disabled = true
	hurtbox_collider.disabled = true
	dash_timer.start(dash_time)

func _on_health_health_changed(amt):
	hit_audio.play()

func _on_health_killed():
	var p = part.instantiate()
	p.global_position = global_position
	get_tree().root.get_child(2).add_child(p)
	queue_free()

func _on_hurtbox_area_entered(hitbox):
	if(hitbox is Bomb):
		return
	health.take_damage(hitbox.damage)
	hitbox.did_damage.emit()

func _on_dash_timer_timeout():
	is_dashing = false
	collider.disabled = false
	hurtbox_collider.disabled = false
