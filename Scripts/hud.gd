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
		print("🎯 Vida actualizada en pantalla: ", value)
	else:
		print("❌ Error: La barra de vida no existe")
