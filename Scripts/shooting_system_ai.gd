extends Marker2D

class_name ShootingSystemAI

@onready var bullet_scene = preload("res://Scenes/bullet.tscn")

var valid_hit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func shoot(look_dir):
	
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.bullet_fired.connect(on_bullet_fired)
	
	bullet.bulletOwner = owner
	bullet.damage = owner.damage_per_bullet
	get_tree().root.add_child(bullet)
	
	#var move_direction = (get_global_mouse_position() - global_position).normalized()
	var move_direction = look_dir
	bullet.move_direction = move_direction
	bullet.global_position = global_position
	bullet.rotation = move_direction.angle()

func on_bullet_fired(hit_valid_target):
	#print("hit_valid_target: ", hit_valid_target)
	valid_hit = hit_valid_target
