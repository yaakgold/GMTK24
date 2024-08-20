extends CharacterBody2D
class_name NumEnemy

@onready var timer = $Timer
@onready var health = $health
@onready var collider = $CollisionPolygon2D
@onready var hurtbox_collider = $Hurtbox/CollisionShape2D
@onready var spawn_spots = $SpawnSpots
@onready var hit_audio = $Hit_Audio

@export var attack_range = 300.0
@export var time_between_shots = 2.5

var bomb = preload("res://scenes/prefabs/bomb.tscn")
var part = preload("res://scenes/prefabs/particles.tscn")

const BOSS_BOMB = preload("res://images/Bomb_bomb.png")
const SPEED = 200.0
const SLOW_DOWN_SPEED = 2.0
const ROTATE_SPEED = 5.0

var player: Player
var can_fire = true
var is_spawned = false

func _physics_process(delta):
	if(!player or !is_spawned):
		return
		
	#Look at player, smoothly
	var v = player.global_position - global_position
	var angle = v.angle()
	var r = global_rotation
	global_rotation = lerp(r, angle, delta * ROTATE_SPEED)

	if(global_position.distance_to(player.global_position) > attack_range):
		velocity = global_position.direction_to(player.global_position) * SPEED
	else:
		#Fire at player
		velocity.x = move_toward(velocity.x, 0, SPEED * SLOW_DOWN_SPEED * delta)
		velocity.y = move_toward(velocity.y, 0, SPEED * SLOW_DOWN_SPEED * delta)
		attempt_fire()
	
	move_and_slide()

func spawn_enemy():
	collider.disabled = false
	hurtbox_collider.disabled = false
	player = get_tree().root.get_child(2).get_node("player")
	is_spawned = true

func attempt_fire():
	if(can_fire):
		can_fire = false
		timer.start(time_between_shots)
		
		for p in spawn_spots.get_children():
			var b = bomb.instantiate()
			b.position = p.global_position
			get_tree().root.add_child(b)
			b.set_collision_layer_value(2, true)
			b.set_collision_layer_value(3, false)
			b.sprite.texture = BOSS_BOMB

func _on_timer_timeout():
	can_fire = true


func _on_health_health_changed(amt):
	hit_audio.play()


func _on_health_killed():
	var p = part.instantiate()
	p.global_position = global_position
	get_tree().root.get_child(2).add_child(p)
	queue_free()

func _on_hurtbox_area_entered(hitbox):
	var parent = hitbox.get_parent()
	if(parent is Player or hitbox is Projectile):
		health.take_damage(hitbox.damage)
		hitbox.did_damage.emit()
