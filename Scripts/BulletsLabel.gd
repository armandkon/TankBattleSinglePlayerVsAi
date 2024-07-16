extends Label

@onready var shooting_system  = $"../../ShootingSystem" as ShootingSystem

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	var bullets_in_magazine = shooting_system.ammo_in_magazine
	#var total_bullets = shooting_system.total_ammo
	var total_bullets = 50
	#var max_ammo = shooting_system.max_ammo
	var max_ammo = 100
	var line1 = "Ammo: " + str(bullets_in_magazine) + "/10"
	var line2 = "Total Ammo: " + str(total_bullets) + "/" + str(max_ammo)
	text = line1 + "\n" + line2
	
