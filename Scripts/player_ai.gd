extends CharacterBody2D

class_name Player_AI

var human_player: Player_Human

@onready var health_system = $HealthSystem as HealthSystem
@onready var shooting_system_ai = $ShootingSystemAI as ShootingSystemAI
@onready var ai_controller = $AIController2D
@onready var ai_sprite = $Sprite2D
@onready var spawn_location = $"../SpawnLocation"

var spawn_points = []

const SPEED = 200.0
var movement_direction: Vector2 =  Vector2.ZERO
var look_action := Vector2(0.0, 0.0)
var can_shoot := true
@export var damage_per_bullet = 5
@export var reload_speed_ms := 500.0
@export var starting_position = Vector2(750, 380)
# REWARD SYSTEM
@export var obstacle_collision_penalty: float
@export var approaching_enemy_reward: float
@export var leaving_enemy_penalty: float
@export var angled_to_enemy_reward: float
@export var not_angled_to_enemy_penalty: float

var enemy_in_line_of_sight_reward: float = 0.1

@export var enemy_completely_out_of_sight_penalty: float
@export var shooting_reward: float
@export var valid_shot_reward: float
@export var missed_target_penalty: float
@export var enemy_takes_damage_reward: float
@export var on_enemy_death_reward: float
@export var take_damage_penalty: float
@export var death_penalty: float
@export var reset_penalty: float

# Enemy's exposed variables to AI
var human_position_x
var human_position_y
var human_velocity: Vector2
var human_bullet_position: Vector2
var human_bullet_direction: Vector2
var human_bullet_rotation: float

var previous_distance_from_enemy = 0.0
var current_distance_from_enemy
var angle_in_radians

var front_ray_to_enemy : RayCast2D
var front_ray_to_obstacle_and_enemy : RayCast2D
# Check if the front ray to the enemy is colliding
var front_ray_collides_with_enemy: bool
# Check if the front ray to the obstacle and enemy is colliding
var front_ray_obstacle_enemy_collision: bool

var max_consecutive_missed_shots = 60 
var current_consecutive_missed_shots = 0  # Timestamp of last time to hit enemy
var consecutive_valid_shots = 0

var total_angle_rewards = 0
var total_not_angled_reward = 0
var total_valid_shot_rewards = 0
var total_kill_rewards = 0
var times_in_on_died = 0
var total_distance_reward = 0
var total_distance_penalty = 0

var total_delta = 0
var max_delta = 30
var time_since_last_check = 0.0
var check_interval = 0.2  # interval in seconds 0.2 interval is checked every 13 deltas, delta = 0.016

var reward : float

func _ready():
	
	for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
		if spawn.has_method("get_position"):
			spawn_points.append(spawn.position)
	
	health_system.died.connect(on_died)

	human_player = get_node("../PlayerHuman")
	
	if(human_player != null):
		print("Human player connected to ai_player, Object: ", human_player)	
		human_player.human_position.connect(on_human_moved)
		human_player.player_shot.connect(on_human_player_shot)
		human_player.player_died.connect(on_human_player_died)
		human_player.bullet_pos_dir.connect(on_human_player_shoots)
	
	front_ray_to_enemy = $FrontRayCastEnemy
	front_ray_to_obstacle_and_enemy = $FrontRayCastObstacleAndEnemy
	
	
		
func _physics_process(delta):
	
	human_velocity = human_player.velocity
		
	total_delta += delta
	if(total_delta > max_delta):		
		total_delta = 0
		respawn()
	
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
		_shoot()
	
# AI penalty when colliding with obstacles/wall
	
	#if(get_last_slide_collision() != null):
		#var collision=get_last_slide_collision()
		#print("Collided with: ", collision.get_collider().name)
		#if(collision.get_collider().name == "TileMap"):
			#ai_controller.reward += obstacle_collision_penalty


# AI receives reward/penalty when approaching or going away from enemy
# Apply continuous reward/penalty based on distance change
	current_distance_from_enemy = position.distance_to(human_player.position)
	#var distance_change = previous_distance_from_enemy - current_distance_from_enemy
	#var reward_factor = 0.004  # A scaling factor for the reward
#
	#if distance_change > 0:
		#ai_controller.reward += reward_factor * distance_change  # Positive reward for approaching
	#else:
		#ai_controller.reward += reward_factor * distance_change  # Negative penalty for leaving
#
	#previous_distance_from_enemy = current_distance_from_enemy

# AI receives reward when facing towards enemy	
	var direction_to_enemy = (human_player.position - position).normalized()	
	var facing_direction = ai_sprite.global_transform.y.normalized()
	
	var dot_product = facing_direction.dot(direction_to_enemy)
	# Clamp to handle floating-point precision issues
	var angle_cosine = clamp(dot_product, -1, 1)  
	
	# Observe angle_in_radian
	angle_in_radians = acos(angle_cosine)
	
	#var angle_in_degrees = rad_to_deg(angle_in_radians)
	#var angle_threshold = deg_to_rad(90)  
	#if angle_in_radians <= angle_threshold:
		#ai_controller.reward += get_angle_reward(angle_in_degrees)
		#total_angle_rewards += get_angle_reward(angle_in_degrees)
	#else:
		#ai_controller.reward -= 0.001
		#total_not_angled_reward -= 0.001
	
	# Check if raycast collides with object or enemy
	
	front_ray_collides_with_enemy = false
		
	if(front_ray_to_enemy.is_colliding()):
		var collider 			
		if(front_ray_to_obstacle_and_enemy.is_colliding()):			
			collider = front_ray_to_obstacle_and_enemy.get_collider()
			if(collider.get_instance_id() == human_player.get_instance_id()):
				#print("Enemy not behind obstacle, raycast collided with: ", collider.name)
				front_ray_collides_with_enemy = true
				ai_controller.reward += enemy_in_line_of_sight_reward
			else:
				#print("Enemy behind obstacle, raycast collided with: ", collider.name)
				front_ray_collides_with_enemy = false
						
	else:
		front_ray_collides_with_enemy = false
				
func _shoot():
	if !can_shoot:
		return
		
	var look_dir = Vector2(cos(rotation), sin(rotation))
	shooting_system_ai.shoot(look_dir)
		
	if(shooting_system_ai.valid_hit):
		# AI hit target
		ai_controller.reward += 2
			
	else:
		# AI missed target
		consecutive_valid_shots = 0
		current_consecutive_missed_shots += 1
		#ai_controller.reward += missed_target_penalty
	
	can_shoot = false
	await get_tree().create_timer(reload_speed_ms/1000.0).timeout
	can_shoot = true
	
func take_damage(damage: int):
	health_system.take_damage(damage)
	#ai_controller.reward += take_damage_penalty

func on_died():
	ai_controller.reward += death_penalty
	respawn()
	
func respawn():
	var ai_chosen_position
	var ai_random_index
	var enemy_chosen_position
	var enemy_random_index
	var random_added_x
	var random_added_y
	
	if spawn_points.size() > 0:
		# Select a random index from the list of positions
		ai_random_index = randi() % spawn_points.size()
		random_added_x = randi_range(-40, 40)
		random_added_y = randi_range(-40, 40)
		ai_chosen_position = spawn_points[ai_random_index]	+ Vector2(random_added_x, random_added_y) 
		position = ai_chosen_position
		
		enemy_random_index = randi() % spawn_points.size()
		random_added_x = randi_range(-40, 40)
		random_added_y = randi_range(-40, 40)
		while(enemy_random_index == ai_random_index):
			enemy_random_index = randi() % spawn_points.size()
		
		enemy_chosen_position = spawn_points[enemy_random_index] + Vector2(random_added_x, random_added_y)
		human_player.position = enemy_chosen_position
		
	else:
		print("No spawn points available!")
	
	human_player.health_system.reset()
	health_system.reset()
	total_delta = 0
	consecutive_valid_shots = 0
	ai_controller.done = true
	ai_controller.reset()

func on_human_player_died():
	ai_controller.reward += 10
	total_kill_rewards += 10
	
	respawn()
	
func on_human_player_shot():
	pass
	
func on_human_moved(x: float, y: float):
	human_position_x = x
	human_position_y = y

func on_human_player_shoots(
	bullet_position: Vector2, 
	bullet_direction: Vector2,
	bullet_rotation: float
	):
		
	human_bullet_position = bullet_position
	human_bullet_direction = bullet_direction
	human_bullet_rotation = bullet_rotation

func get_angle_reward(angle):
	if angle <= 1:
		return 0.0010
	elif angle <= 5:
		return 0.00075
	elif angle <= 10:
		return 0.0005
	elif angle <= 20:
		return 0.00035
	elif angle <= 30:
		return 0.00025
	elif angle <= 45:
		return 0.00020
	elif angle <= 60:
		return 0.00015
	elif angle <= 75:
		return 0.00010
	elif angle <= 90:
		return 0.00007
	elif angle <= 120:
		return 0.00004
	elif angle <= 150:
		return 0.00002
	elif angle <= 180:
		return 0.00001
	else:
		return 0.0

