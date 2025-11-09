extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/HealthBar

func setup(health_component: HealthComponent = null, weight_component: WeightComponent = null):
	if health_component == null:
		print("❌ Error: No se dio componente de vida al HUD")
		return
	
	if not is_instance_valid(health_component):
		print("❌ Error: El componente de vida no es válido")
		return
	
	# Configurar vida
	health_bar.value = health_component.health
	health_bar.max_value = health_component.max_health
	health_component.health_changed.connect(_on_health_changed)
	print("✅ HUD listo con vida inicial: ", health_component.health, "/", health_component.max_health)
	
	# Si se proporciona componente de peso, mostrar info
	if weight_component != null:
		print("✅ HUD también recibió componente de peso: ", weight_component.weight, "kg")

func _on_health_changed(value):
	if is_instance_valid(health_bar):
		health_bar.value = value
		_update_health_bar_color(value)
		print("🎯 Vida actualizada en pantalla: ", value)
	else:
		print("❌ Error: La barra de vida no existe")

func _update_health_bar_color(health_value: float):
	if not health_bar:
		return
		
	var health_percent = health_value / health_bar.max_value
	var style = StyleBoxFlat.new()
	
	# Configurar esquinas redondeadas
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	
	# Determinar color basado en el porcentaje de vida
	if health_percent > 0.7: # 70-100% - Verde
		style.bg_color = Color(0.0, 0.8, 0.0)  # Verde brillante
	elif health_percent > 0.4: # 40-70% - Amarillo
		style.bg_color = Color(0.9, 0.9, 0.0)  # Amarillo
	elif health_percent > 0.2: # 20-40% - Naranja
		style.bg_color = Color(1.0, 0.5, 0.0)  # Naranja
	else: # 0-20% - Rojo
		style.bg_color = Color(1.0, 0.0, 0.0)  # Rojo
	
	health_bar.add_theme_stylebox_override("fill", style)
