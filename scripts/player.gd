extends CharacterBody2D
class_name Player

@onready var proj_position = $Proj_Position_Holder/Proj_Position
@onready var proj_position_holder = $Proj_Position_Holder
@onready var health: Health = $health
@onready var dash_timer = $Dash_Timer
@onready var fire_timer = $Fire_Timer
@onready var collider = $CollisionPolygon2D
@onready var hurtbox_collider = $Hurtbox/CollisionShape2D
@onready var bomb_timer = $Bomb_Timer
@onready var sprite = $CollisionPolygon2D/Sprite2D

@onready var dash_audio = $Dash_Audio
@onready var fire_audio = $Fire_Audio
@onready var hit_audio = $Hit_Audio
@onready var death_audio = $Death_Audio

@export var dash_time = .15
@export var game: GameController

const SPEED = 300.0
const SLOW_DOWN_SPEED = 2.0
const DASH_SPEED_MULT = 3

const MAIN_ICON = preload("res://images/main_icon.png")
const DASH_ICON = preload("res://images/dash_icon.png")

var proj = preload("res://scenes/prefabs/projectile.tscn")
var bomb = preload("res://scenes/prefabs/bomb.tscn")

var is_dashing = false
var can_place_bomb = true
var can_fire = true

func _physics_process(delta):
	update_movement(delta)
	aim_and_fire()
	

func update_movement(delta):
	if(!is_dashing && Input.is_action_just_pressed("dash")):
		dash_audio.play()
		sprite.texture = DASH_ICON
		is_dashing = true
		collider.disabled = true
		hurtbox_collider.disabled = true
		dash_timer.start()
	
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
	look_at(get_global_mouse_position())
	rotate(deg_to_rad(90))
	#proj_position_holder.look_at(get_global_mouse_position()) #Need to add an extra 90 deg rotation
	#proj_position_holder.rotate(deg_to_rad(90))
	
	#Fire
	if(Input.is_action_pressed("fire") and can_fire):
		fire_audio.play()
		can_fire = false
		fire_timer.start()
		var p: Projectile = proj.instantiate()
		p.position = proj_position.global_position
		get_tree().root.add_child(p)
		p.fire(400, get_global_mouse_position(), Color(0, 1, 0), true)
		
	if(Input.is_action_just_pressed("place") and can_place_bomb):
		var b: Bomb = bomb.instantiate()
		get_tree().root.add_child(b)
		b.position = global_position
		b.is_player = true
		can_place_bomb = false
		bomb_timer.start(.75)
		
func _on_health_health_changed(amt):
	if(amt > 0): #This mean damage was taken
		print("Ouch: " + str(amt))
	else:
		print("Yummy: " + str(amt))

func _on_health_killed():
	death_audio.play()
	var game: GameController = get_tree().root.get_child(2)
	game.player_death.emit(self)

func _on_dash_timer_timeout():
	sprite.texture = MAIN_ICON
	is_dashing = false
	collider.disabled = false
	hurtbox_collider.disabled = false

func _on_hurtbox_area_entered(hitbox):
	if(hitbox is Projectile or (hitbox.get_parent() is LowEnemy and hitbox.get_parent().is_dashing)):
		health.take_damage(hitbox.damage)
		hit_audio.play()

func _on_bomb_timer_timeout():
	can_place_bomb = true

func _on_fire_timer_timeout():
	can_fire = true
