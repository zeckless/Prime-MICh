extends Area2D

func _on_body_entered(body):
	if body.name == "player" or body.is_in_group("player"):
		GameManager.ultimo_checkpoint_pos = global_position
		print("¡Progreso guardado en: ", global_position, "!")
		
