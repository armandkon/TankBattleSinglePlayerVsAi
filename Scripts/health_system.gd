extends Node

class_name HealthSystem

signal got_shot
signal died
signal damage_taken(current_health: int)

@export var base_health = 25
var current_health

func _ready():
	current_health = base_health
	
func take_damage(damage: int):
	
	current_health -= damage
	damage_taken.emit(current_health)
	got_shot.emit()
	if current_health <= 0:
		died.emit()

func take_mock_damage(damage: int):
	
	pass
		
func reset():
	current_health = base_health
	damage_taken.emit(current_health)
