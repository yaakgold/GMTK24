extends CharacterBody2D

@onready var collider = $CollisionShape2D
@onready var hurtbox_collider = $Hurtbox/CollisionShape2D
@onready var health = $health
@onready var spawn_points = $SpawnPoints
@onready var fire_audio = $Fire_Audio
@onready var hit_audio = $Hit_Audio

const GAME_RED = preload("res://game_red.tres")
const ENEMY_CAP = preload("res://scenes/prefabs/enemy_cap_boss.tscn")
const ENEMY_LOW = preload("res://scenes/prefabs/enemy_low_boss.tscn")
const ENEMY_NUM = preload("res://scenes/prefabs/enemy_num.tscn")
const BOSS_BOMB = preload("res://images/Bomb_bomb.png")
const PROJ = preload("res://scenes/prefabs/projectile.tscn")
const BOMB = preload("res://scenes/prefabs/bomb.tscn")
const SPEED = 500.0
const FIRE_PROB = .4
const BOMB_PROB = .36
const ENEM_PROB = .24

var part = preload("res://scenes/prefabs/particles.tscn")

var current_state: eState = eState.IDLE
var rng = RandomNumberGenerator.new()
var target_location = null
var is_doing_action = false
var player: Player
var is_dead = false

func _physics_process(delta):
	if(player == null):
		return
	match current_state:
		eState.IDLE:
			pass
		eState.MOVING:
			do_move()
		eState.FIRE_PROJ:
			do_fire_proj()
		eState.THROW_BOMBS:
			do_throw_bombs()
		eState.SPAWN_ENEMIES:
			do_spawn_enemies()

func do_move():
	if(target_location == null):
		var screenSize = get_viewport().get_visible_rect().size
		var rndX = rng.randf_range(-450.0, 450.0)
		var rndY = rng.randf_range(-800.0, -270.0)
		target_location = Vector2(rndX, rndY)

	if(position.distance_to(target_location) < 5):
		var rand = rng.randf()
		if(rand <= ENEM_PROB):
			current_state = eState.SPAWN_ENEMIES
		elif(rand <= BOMB_PROB):
			current_state = eState.THROW_BOMBS
		else:
			current_state = eState.FIRE_PROJ
			
		target_location = null
		velocity = Vector2.ZERO
	else:
		velocity = position.direction_to(target_location) * SPEED
	
	move_and_slide()
	
func do_fire_proj():
	if(is_doing_action):
		return
	is_doing_action = true
	
	fire_audio.play()
	for p in spawn_points.get_children():
		var proj = PROJ.instantiate()
		proj.position = p.global_position
		get_tree().root.add_child(proj)
		proj.fire(800, player.global_position, Color(0, 0, 1), false)
	await get_tree().create_timer(2).timeout
	current_state = eState.MOVING
	is_doing_action = false

func do_throw_bombs():
	if(is_doing_action):
		return
	is_doing_action = true
	
	for p in spawn_points.get_children():
		if p.is_in_group("bombs"):
			var b = BOMB.instantiate()
			b.position = p.global_position
			get_tree().root.add_child(b)
			b.set_collision_layer_value(2, true)
			b.set_collision_layer_value(3, false)
			b.sprite.texture = BOSS_BOMB
			b.particles.color = Color("#78009b")
	
	await get_tree().create_timer(1).timeout
	current_state = eState.MOVING
	is_doing_action = false

func do_spawn_enemies():
	if(is_doing_action):
		return
	is_doing_action = true
	
	for p in spawn_points.get_children():
		if p.is_in_group("bombs"):
			var rand = rng.randi_range(0, 2)
			if(rand == 0):
				var e = ENEMY_CAP.instantiate()
				e.position = p.global_position
				get_tree().root.get_child(2).add_child(e)
				e.get_node("Label").text = "B"
				e.spawn_enemy()
				e.add_to_group("enemies")
			elif(rand == 1):
				var e = ENEMY_LOW.instantiate()
				e.position = p.global_position
				get_tree().root.get_child(2).add_child(e)
				e.get_node("Label").text = "b"
				e.spawn_enemy()
				e.add_to_group("enemies")
			else:
				var e = ENEMY_NUM.instantiate()
				e.position = p.global_position
				get_tree().root.get_child(2).add_child(e)
				e.get_node("Label").text = "9"
				e.get_node("Label").label_settings = GAME_RED
				e.spawn_enemy()
				e.add_to_group("enemies")
	
	await get_tree().create_timer(4).timeout
	current_state = eState.MOVING
	is_doing_action = false

func spawn_enemy():
	player = get_tree().root.get_child(2).get_node("player")
	collider.disabled = false
	hurtbox_collider.disabled = false
	current_state = eState.MOVING
	health.set_ui.emit()

func _on_hurtbox_area_entered(hitbox):
	if(hitbox is Projectile or (hitbox.get_parent() is Player and hitbox.get_parent().is_dashing)):
		health.take_damage(hitbox.damage)
		hitbox.did_damage.emit()
		hit_audio.play()

func _on_health_killed():
	if(is_dead):
		return
	
	is_dead = true
	get_tree().call_group("enemies", "_on_health_killed")
	var p = part.instantiate()
	p.global_position = global_position
	get_tree().root.get_child(2).add_child(p)
	queue_free()

enum eState { IDLE, MOVING, FIRE_PROJ, THROW_BOMBS, SPAWN_ENEMIES }
