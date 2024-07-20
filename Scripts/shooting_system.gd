extends Marker2D

class_name ShootingSystem

signal shot(ammo_in_magazine: int, bullet_position: Vector2, bullet_direction: Vector2, bullet_angle: Vector2)
signal gun_reload(ammo_in_magazine: int, ammo_left: int)
signal ammo_added(total_ammo: int)
#signal bullet_position(global_position: Vector2)
#signal bullet_direction(direction: Vector2)

@export var max_ammo = 10000
@export var total_ammo = 10000
@export var magazine_size = 10000
@export var damage_per_bullet = 5
var can_shoot := true
@export var reload_speed_ms := 500.0

@onready var bullet_scene = preload("res://Scenes/bullet.tscn")

var ammo_in_magazine = 0
var bullet_position: Vector2
var bullet_direction: Vector2
var bullet_rotation: float

var isReloading = false

var crosshair_texture = preload("res://Sunny Land Collection Files/Packs/crosshair_white-export.png")
#var crosshair_texture = preload("res://Sunny Land Collection Files/Packs/crosshair_white.png")
#var crosshair_texture = preload("res://Sunny Land Collection Files/Packs/crosshair.png")

func _ready():
	Input.set_custom_mouse_cursor(crosshair_texture)
	ammo_in_magazine = magazine_size

func _input(event):
	if Input.is_action_just_pressed("shoot"):
		if(!isReloading):
			if !can_shoot:
				return
				
			shoot()
			
			can_shoot = false
			await get_tree().create_timer(reload_speed_ms/1000.0).timeout
			can_shoot = true
		else:
			print("Reloading, cant't shoot")
	if Input.is_action_just_pressed("reload"):
		if(!isReloading):
			reload()
		else:
			print("Already reloading, cant' reload")

func shoot():
	if ammo_in_magazine == 0:
		return
	
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.bulletOwner = owner
	bullet.damage = owner.damage_per_bullet	
	get_tree().root.add_child(bullet)
	
	var move_direction = (get_global_mouse_position() - global_position).normalized()
	bullet.move_direction = move_direction
	bullet.global_position = global_position
	bullet.rotation = move_direction.angle()
	
#	track bullet global position and rotation 
#	expose signal to ai_player in order to observe

	#print("bullet.move_direction: ", bullet.move_direction)
	#print("bullet.global_position: ", bullet.global_position)
	#print("bullet.rotation: ", bullet.rotation)
	
	#bullet_position.emit(bullet.global_position)
	#bullet_direction.emit(bullet.move_direction)
	bullet_position = bullet.global_position
	bullet_direction = bullet.move_direction
	bullet_rotation = bullet.rotation
	ammo_in_magazine -= 1
	shot.emit(ammo_in_magazine, bullet_position, bullet_direction, bullet_rotation)
		
func reload():	
	
	#if total_ammo <= 0:
		#print("Not enough ammo")
		#return
	
	isReloading = true
	$Timer.start()

func _on_timer_timeout():
	
	if(ammo_in_magazine < magazine_size):
		ammo_in_magazine += 1
		gun_reload.emit(ammo_in_magazine, 50) 
	
	if(ammo_in_magazine == magazine_size):
		isReloading = false
		$Timer.stop()
