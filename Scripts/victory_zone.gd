extends Area2D

func _ready():
	# Conectar la señal de colisión si no se conectó desde el editor
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	print("✅ VictoryZone lista - ¡Cualquiera que entre gana!")

func _on_body_entered(body):
	print("⚡ Algo entró en la zona de victoria: ", body.name)
	
	# Única condición: ¿Es el jugador?
	if body.is_in_group("player"):
		print("🏆 ¡JUGADOR DETECTADO! Activando victoria...")
		call_deferred("show_victory")
	else:
		print("❌ Objeto ignorado (no es el jugador)")

func show_victory():
	# Evitar que se active más de una vez
	if not is_monitoring():
		return

	print("🎮 Cargando escena de victoria...")
	
	# Verificar si ya existe una escena de victoria (seguridad extra)
	for node in get_tree().root.get_children():
		if node.name.begins_with("Victory"):
			print("⚠️ Ya existe una escena de victoria activa")
			return
	
	# Desactivar la zona para que no vuelva a detectar nada
	set_deferred("monitoring", false)
	
	# Crear la escena de victoria
	var victory_scene = load("res://Scenes/victory.tscn").instantiate()
	get_tree().root.add_child(victory_scene)
	print("✨ ¡Victoria mostrada correctamente!")
