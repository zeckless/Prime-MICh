extends CanvasLayer

@onready var weight_bar: ProgressBar = $MarginContainer/ProgressBar
var weight_component_ref: WeightComponent = null

func _ready():
	print("✅ HUDpeso inicializado correctamente")
	if weight_bar:
		print("✅ ProgressBar encontrada: ", weight_bar.name)
		print("🔧 Configuración inicial barra - Min: ", weight_bar.min_value, " Max: ", weight_bar.max_value, " Valor: ", weight_bar.value)
	else:
		print("❌ ProgressBar NO encontrada")

func setup_weight(weight_component: WeightComponent = null):
	print("🔄 Configurando HUD de peso...")
	
	if weight_component == null:
		print("❌ Error: No se proporcionó WeightComponent")
		return false
	
	if not weight_bar:
		print("❌ Error: ProgressBar no encontrada")
		return false
	
	# Guardar referencia
	weight_component_ref = weight_component
	
	# Configurar barra - FORZAR CONFIGURACIÓN
	weight_bar.min_value = 1.0
	weight_bar.max_value = 5.0
	weight_bar.step = 1.0
	weight_bar.value = float(weight_component.get_current_level())
	
	# Forzar actualización visual
	weight_bar.queue_redraw()
	
	print("🎯 Barra configurada - Min: ", weight_bar.min_value, " Max: ", weight_bar.max_value, " Valor: ", weight_bar.value)
	
	# Desconectar señal previa si existe
	if weight_component.weight_changed.is_connected(_on_weight_changed):
		weight_component.weight_changed.disconnect(_on_weight_changed)
		print("⚠️ Señal previa desconectada")
	
	# Conectar señal
	weight_component.weight_changed.connect(_on_weight_changed)
	print("✅ Señal weight_changed conectada")
	
	# Test inicial
	print("✅ HUD de peso configurado: ", weight_component.weight, "kg → nivel ", weight_bar.value, "/5")
	return true

func _on_weight_changed(new_weight_value):
	print("🎯 ¡SEÑAL RECIBIDA! Peso: ", new_weight_value, "kg")
	
	if not weight_component_ref or not weight_bar:
		print("❌ Error: Referencias nulas")
		return
	
	var new_level = weight_component_ref.get_current_level()
	var old_value = weight_bar.value
	
	# Actualizar valor
	weight_bar.value = float(new_level)
	
	# Forzar actualización visual
	weight_bar.queue_redraw()
	
	print("⚖️ Barra actualizada: ", old_value, " → ", weight_bar.value, " (", new_weight_value, "kg)")
	print("🔧 Estado barra después - Min: ", weight_bar.min_value, " Max: ", weight_bar.max_value, " Valor: ", weight_bar.value)
