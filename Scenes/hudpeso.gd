extends CanvasLayer

@onready var weight_bar: ProgressBar = $MarginContainer/WeightBar
@onready var weight_label: Label = $MarginContainer/WeightLabel
var weight_component_ref: WeightComponent = null

func _ready():
	print("✅ HUDpeso inicializado correctamente")
	if weight_bar:
		print("✅ ProgressBar encontrada: ", weight_bar.name)
		print("🔧 Configuración inicial barra - Min: ", weight_bar.min_value, " Max: ", weight_bar.max_value, " Valor: ", weight_bar.value)
	else:
		print("❌ ProgressBar NO encontrada")
	
	# Crear y configurar el Label si no existe
	if not weight_label:
		var new_label = Label.new()
		new_label.name = "WeightLabel"
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		$MarginContainer.add_child(new_label)
		weight_label = new_label
		print("✅ WeightLabel creado dinámicamente")

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
	
	# Configurar barra con los valores exactos de peso
	weight_bar.min_value = 37.0  # Peso mínimo
	weight_bar.max_value = 100.0  # Peso máximo
	weight_bar.value = weight_component.weight  # Peso actual
	
	# Configurar etiqueta
	_update_weight_display(weight_component.weight, weight_component.get_current_level())
	
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
	
	var old_value = weight_bar.value
	
	# Actualizar valor directamente con el peso
	weight_bar.value = new_weight_value
	
	# Actualizar etiqueta
	_update_weight_display(new_weight_value, 0)
	
	# Forzar actualización visual
	weight_bar.queue_redraw()
	
	print("⚖️ Barra actualizada: ", old_value, " → ", weight_bar.value, " (", new_weight_value, "kg)")
	print("🔧 Estado barra después - Min: ", weight_bar.min_value, " Max: ", weight_bar.max_value, " Valor: ", weight_bar.value)

func _update_weight_display(weight_kg: float, _unused: int = 0):
	if not weight_label:
		return
	
	var description = ""
	var color = Color.WHITE
	
	# Determinar descripción y color basado en el peso actual
	if weight_kg <= 37:
		description = "LIGERO"
		color = Color.CYAN
	elif weight_kg <= 50:
		description = "NORMAL"
		color = Color.GREEN
	elif weight_kg <= 75:
		description = "MEDIO"
		color = Color.YELLOW
	else:
		description = "PESADO"
		color = Color.RED
	
	# Actualizar texto (solo mostrar el peso)
	weight_label.text = str(int(weight_kg)) + "kg"
	weight_label.modulate = color  # Mantener los colores según el peso
	
	# Actualizar color de la barra de progreso
	if weight_bar:
		var style = StyleBoxFlat.new()
		style.bg_color = color
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_right = 4
		style.corner_radius_bottom_left = 4
		weight_bar.add_theme_stylebox_override("fill", style)
