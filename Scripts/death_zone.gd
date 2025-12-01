extends Area2D

func _ready() -> void:
	# Conectamos la señal automáticamente al iniciar
	# (Asegúrate de no haberla conectado ya manualmente en el editor para que no se duplique)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Verificamos si lo que entró es el Jugador
	if body.is_in_group("player"):
		print("💀 El jugador ha entrado en la Zona de Muerte")
		
		# OPCIÓN 1: Usar tu sistema de daño (Recomendada)
		# Le hacemos daño infinito para asegurar que la vida baje a 0
		# y se active el HealthComponent -> signal died -> _on_died()
		if body.has_method("take_damage"):
			body.take_damage(999999)
			
		# OPCIÓN 2: Forzar muerte directa (Plan B)
		# Si por alguna razón take_damage falla, llamamos a die() directo
		elif body.has_method("die"):
			body.die()
		
		# OPCIÓN 3: Fallback de emergencia
		else:
			print("⚠️ El jugador no tiene método de muerte, reiniciando escena a la fuerza")
			get_tree().reload_current_scene()
