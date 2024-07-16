extends CharacterBody2D

class_name Player_AI

var human_player: Player_Human

@onready var health_system = $HealthSystem as HealthSystem
@onready var shooting_system_ai = $ShootingSystemAI as ShootingSystemAI
@onready var ai_controller = $AIController2D

const SPEED = 200.0
var movement_direction: Vector2 =  Vector2.ZERO
var look_action := Vector2(0.0, 0.0)
var can_shoot := true
@export var damage_per_bullet = 5
@export var reload_speed_ms := 500.0
@export var starting_position = Vector2(750, 380)

var human_position_x
var human_position_y
var human_bullet_position: Vector2
var human_bullet_direction: Vector2
var human_bullet_rotation: float

# SOS
# Mporei na min xreiazetai to multiplayer Synchronizer

func _ready():
	health_system.died.connect(on_died)

	human_player = get_node("../PlayerHuman")
	
	if(human_player != null):
		print("Human player connected to ai_plauyer")	
		print(human_player)	
		human_player.human_position.connect(on_human_moved)
		human_player.player_shot.connect(on_human_player_shot)
		human_player.player_died.connect(on_human_player_died)
		human_player.bullet_pos_dir.connect(on_human_player_shoots)
		
func _physics_process(delta):
	
# AI movement in 2D-plane
	velocity.x = ai_controller.move.x * ai_controller.speed_multiplier
	velocity.y = ai_controller.move.y * ai_controller.speed_multiplier
	
	move_and_slide()

# AI rotation in 2D-plane
	var look_dir = ai_controller.look_action
	if look_dir.length() > 0:
		var target_angle = look_dir.angle()
		rotation = lerp_angle(rotation, target_angle, ai_controller.rotation_speed * delta)
		
# AI shooting action, receives 0 or 1, shoots if 1, doesn't shoot if 0
	var shoot
	shoot = ai_controller.shoot_action
	if(shoot):
	#if(can_shoot):
		_shoot()
	
# AI position reset when colliding with obstacles/wall
	
	if(get_last_slide_collision() != null):
		#print(get_last_slide_collision())
		var collision=get_last_slide_collision()
		#print("Collided with: ", collision.get_collider().name)
		if(collision.get_collider().name == "TileMap"):
			#possibly remove reward reduction on obstacle callision
			ai_controller.reward -= 1.0
			respawn()
			pass

func _shoot():
	if !can_shoot:
		return
		
	var look_dir = Vector2(cos(rotation), sin(rotation))
	shooting_system_ai.shoot(look_dir)
	
	ai_controller.reward += 1.0
		
	if(shooting_system_ai.valid_hit):
		#print("ai_hit_target")
		ai_controller.reward += 10.0
	else:
		#print("ai_missed_target")
		ai_controller.reward -= 0.2
	
	can_shoot = false
	await get_tree().create_timer(reload_speed_ms/1000.0).timeout
	can_shoot = true
	
func take_damage(damage: int):
	health_system.take_damage(damage)
	ai_controller.reward -= 1.0

func on_died():
	ai_controller.reward -= 10.0
	ai_controller.done = true
	respawn()
	
func respawn():
	position = starting_position
	health_system.reset()
	ai_controller.reset()

func on_human_player_died():
	ai_controller.reward += 100.0
	respawn()
	
func on_human_player_shot():
	ai_controller.reward += 20.0
	
func on_human_moved(x: float, y: float):
	human_position_x = x
	human_position_y = y

func on_human_player_shoots(
	bullet_position: Vector2, 
	bullet_direction: Vector2,
	bullet_rotation: float):
		
	human_bullet_position = bullet_position
	human_bullet_direction = bullet_direction
	human_bullet_rotation = bullet_rotation
	
