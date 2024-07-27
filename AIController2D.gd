extends AIController2D

@onready var player_ai = $".."

var move = Vector2.ZERO
var look_action := Vector2(0.0, 0.0)
var shoot_action := false

var speed_multiplier = 100.0
var rotation_speed = 3.0

func get_obs() -> Dictionary:
	
	#print("player_ai.human_bullet_position.x: ", player_ai.human_bullet_position.x)
	#print("player_ai.human_bullet_position.y: ", player_ai.human_bullet_position.y)
	#print("player_ai.human_bullet_direction.x: ", player_ai.human_bullet_direction.x)
	#print("player_ai.human_bullet_direction.y: ", player_ai.human_bullet_direction.y)
	#print("player_ai.velocity.x: ", player_ai.velocity.x)
	#print("player_ai.velocity.y: ", player_ai.velocity.y)
	#print("human_player.velocity.x: ", player_ai.human_velocity.x)
	#print("human_player.velocity.y: ", player_ai.human_velocity.y)	
	
	return {"obs":[
		player_ai.global_position.x,
		player_ai.global_position.y,
		player_ai.velocity.x,
		player_ai.velocity.y,
		player_ai.human_position_x,
		player_ai.human_position_y,
		player_ai.global_rotation,
		player_ai.current_distance_from_enemy,		
		player_ai.angle_in_radians,
		player_ai.front_ray_collides_with_enemy,		
		player_ai.human_velocity.x,
		player_ai.human_velocity.y,
		#player_ai.human_bullet_position.x,
		#player_ai.human_bullet_position.y,
		#player_ai.human_bullet_direction.x,
		#player_ai.human_bullet_direction.y,
		#player_ai.human_bullet_rotation
	]}



func get_reward() -> float:	
	return reward
	
func get_action_space() -> Dictionary: 
	return {
		"move" : {
			"size": 2,
			"action_type": "continuous"
		},
		"look_action" : {
			"size": 2,
			"action_type": "continuous"
		},
		"shoot_action" : {
			"size": 2,
			"action_type": "discrete"
		},
		}
	
func set_action(action) -> void:	
	move.x = action["move"][0]
	move.y = action["move"][1]
	look_action =  Vector2(clamp(action["look_action"][0],-1.0,1.0), clamp(action["look_action"][1],-1.0,1.0))
	shoot_action = action["shoot_action"] == 1
