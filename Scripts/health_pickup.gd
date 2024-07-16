extends Area2D

const HEALTH_AMOUNT_RESTORED = 3

func _on_body_entered(body):
	(body as Player_Human).on_health_pickup(HEALTH_AMOUNT_RESTORED)
	queue_free()
