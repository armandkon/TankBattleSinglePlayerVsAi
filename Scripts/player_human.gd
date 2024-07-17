extends CharacterBody2D

class_name Player_Human

signal player_shot
signal player_died
signal human_position(x: float, y: float)
signal bullet_pos_dir(bullet_position: Vector2, bullet_direction: Vector2, bullet_rotation: float)

@onready var health_system = $HealthSystem as HealthSystem
@onready var shooting_system = $ShootingSystem as ShootingSystem

@export var damage_per_bullet = 5
@export var speed = 200
@export var rotation_speed = 20

var movement_direction: Vector2 =  Vector2.ZERO
var angle

func _ready():
	health_system.died.connect(on_died)
	health_system.got_shot.connect(on_getting_shot)
			
	$CanvasLayer.visible = true
	shooting_system.shot.connect(on_shot)	

func _physics_process(delta):
	
	velocity = movement_direction * speed	
	if angle:
		global_rotation = lerp_angle(global_rotation, angle, delta * rotation_speed)
		
	move_and_slide()
	
	human_position.emit(global_position.x, global_position.y)
	
func _input(event):
	
	if Input.is_action_pressed("move_down"):
		movement_direction = Vector2.DOWN
	elif Input.is_action_pressed("move_up"):
		movement_direction = Vector2.UP
	elif Input.is_action_pressed("move_right"):
		movement_direction = Vector2.RIGHT
	elif Input.is_action_pressed("move_left"):
		movement_direction = Vector2.LEFT
	else:
		movement_direction = Vector2.ZERO
	
	angle = (get_global_mouse_position() - global_position).angle()
	
func take_damage(damage: int):
	health_system.take_damage(damage)
	#print(health_system.current_health)

func on_died():
	#print("Human Player died! Player's print")
	health_system.reset()
	player_died.emit()
	
	#queue_free()

func on_getting_shot():
	#print("Human Player got shot! Player's print")
	player_shot.emit()
	
func on_shot(
	ammo_in_magazine: int, 
	bullet_position: Vector2, 
	bullet_direction: Vector2, 
	bullet_rotation: float):
		
	#print("Human Player shot a bullet! Player's print")
	#print("bullet_position: ", bullet_position)
	#print("bullet_direction: ", bullet_direction)
	#print("bullet_rotation: ", bullet_rotation)
	bullet_pos_dir.emit(bullet_position, bullet_direction, bullet_rotation)
