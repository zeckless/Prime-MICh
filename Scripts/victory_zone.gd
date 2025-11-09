extends Area2D

@export var required_weight = 50.0  # Peso requerido para ganar
@export var weight_tolerance = 5.0  # Margen de error permitido

func _ready():
	# Conectar la señal de colisión
	body_entered.connect(_on_body_entered)
	print("✅ VictoryZone iniciada - Esperando jugador con peso ", required_weight, "kg (±", weight_tolerance, "kg)")
	
	# Verificar la configuración de colisiones
	print("🎯 Configuración de colisiones:")
	print("- Collision Layer: ", collision_layer)
	print("- Collision Mask: ", collision_mask)
	
func _physics_process(_delta):
	# Verificación constante de objetos cercanos
	var overlapping = get_overlapping_bodies()
	if overlapping.size() > 0:
		print("🔍 Objetos en la zona: ", overlapping.size())
		for body in overlapping:
			print("- ", body.name, " (grupos: ", body.get_groups(), ")")

func _on_body_entered(body):
	print("⚡ Algo entró en la zona de victoria: ", body.name)
	
	# Verificar si es el jugador
	if not body.is_in_group("player"):
		print("❌ No es el jugador")
		return
	
	# Verificar componente de peso
	var weight_component = body.get_node_or_null("WeightComponent")
	if not weight_component:
		print("❌ El objeto no tiene componente de peso")
		return
	
	# Verificar el peso
	var current_weight = weight_component.weight
	print("⚖️ Peso actual: ", current_weight, "kg vs requerido: ", required_weight, "kg")
	
	if abs(current_weight - required_weight) <= weight_tolerance:
		print("🏆 ¡PESO CORRECTO! Mostrando victoria")
		call_deferred("show_victory")
	else:
		print("❌ Peso incorrecto - Diferencia: ", abs(current_weight - required_weight), "kg")

func show_victory():
	print("🎮 Cargando escena de victoria...")
	
	# Verificar si ya existe una escena de victoria
	for node in get_tree().root.get_children():
		if node.name.begins_with("Victory"):
			print("❌ Ya existe una escena de victoria")
			return
	
	# Crear la escena de victoria
	var victory_scene = load("res://Scenes/victory.tscn").instantiate()
	
	# Desactivar la zona de victoria para evitar múltiples activaciones
	set_deferred("monitoring", false)
	
	# Añadir la escena
	get_tree().root.add_child(victory_scene)
	print("✨ Victoria mostrada correctamente")