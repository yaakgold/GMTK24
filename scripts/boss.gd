extends CharacterBody2D

@onready var collider = $CollisionShape2D
@onready var hurtbox_collider = $Hurtbox/CollisionShape2D
@onready var health = $health


func spawn_enemy():
	collider.disabled = false
	hurtbox_collider.disabled = false
