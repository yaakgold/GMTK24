extends CharacterBody2D
class_name CapEnemy

@onready var timer = $Timer
@onready var proj_position = $Proj_Position_Holder/Proj_Position
@onready var proj_position_holder = $Proj_Position_Holder
@onready var health = $health

@export var attack_range = 300.0
@export var time_between_shots = 1.0

var proj = preload("res://scenes/prefabs/projectile.tscn")

const SPEED = 200.0
const SLOW_DOWN_SPEED = 2.0
const ROTATE_SPEED = 5.0

var player: Player
var can_fire = true
var is_spawned = false

func _ready():
	player = get_tree().root.get_child(0).get_node("player")

func _physics_process(delta):
	if(!player or !is_spawned):
		return
	
	#Look at player, smoothly
	var v = player.global_position - global_position
	var angle = v.angle()
	var r = global_rotation
	global_rotation = lerp(r, angle, delta * ROTATE_SPEED)
	
	#proj_position_holder.look_at(player.position) #Need to add an extra 90 deg rotation
	#proj_position_holder.rotate(deg_to_rad(90))
	
	if(position.distance_to(player.position) > attack_range):
		velocity = position.direction_to(player.position) * SPEED
	else:
		#Fire at player
		velocity.x = move_toward(velocity.x, 0, SPEED * SLOW_DOWN_SPEED * delta)
		velocity.y = move_toward(velocity.y, 0, SPEED * SLOW_DOWN_SPEED * delta)
		attempt_fire()
	
	move_and_slide()

func spawn_enemy():
	#TODO: Set start animation
	is_spawned = true

func attempt_fire():
	if(can_fire):
		can_fire = false
		timer.start(time_between_shots)
		
		var p: Projectile = proj.instantiate()
		p.position = proj_position.global_position
		get_tree().root.add_child(p)
		p.fire(400, player.position, Color(1, 0, 0), false)

func _on_timer_timeout():
	can_fire = true


func _on_health_health_changed(amt):
	pass


func _on_health_killed():
	queue_free()
	#TODO: Make death animation


func _on_hurtbox_area_entered(hitbox):
	health.take_damage(hitbox.damage)
	hitbox.did_damage.emit()
