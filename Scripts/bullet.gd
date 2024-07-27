extends Area2D

class_name Bullet

signal bullet_fired(hit_valid_target)

@export var speed = 600
var move_direction: Vector2 = Vector2.ZERO
var damage
var bulletOwner = null
var hit_valid_target

func _ready():
	move_direction = Vector2(1,0).rotated(rotation)

func _process(delta):
	global_position += move_direction * delta * speed

func _on_body_entered(body):
	
	if body != bulletOwner:
		if body is Player_Human:
			body.take_damage(damage)
			hit_valid_target = true
		elif body is Player_AI:
			body.take_damage(damage)
		else:
			hit_valid_target = false
		bullet_fired.emit(hit_valid_target)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
