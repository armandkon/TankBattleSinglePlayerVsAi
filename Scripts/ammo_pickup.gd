extends Area2D

func _on_body_entered(body):
		(body as Player_Human).on_ammo_pickup()# Replace with function body.
		queue_free()
