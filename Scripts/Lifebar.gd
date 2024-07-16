extends ProgressBar

class_name PlayerLifeBar

@onready var health_system = $"../HealthSystem" as HealthSystem

func _ready():
	max_value = health_system.base_health
	health_system.damage_taken.connect(on_damage_taken)
	#health_system.died.connect(on_died) test signal uncomment if wanna use, problably not
	value = max_value

func on_damage_taken(current_health):
	value = current_health
	
#func on_died():
	 # einai Test signal de xreiazetai
	#print("PROSEXE RE MALAKA, PETAHANA!!! MESA APO TIN on_died tou progressbar")

