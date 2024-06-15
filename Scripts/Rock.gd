extends StaticBody3D

func damage():
	queue_free()

func _on_damage_zone_body_entered(body):
	if body.has_method("damage_player"):
		body.damage_player()
