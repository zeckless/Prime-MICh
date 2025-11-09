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
	
	# Configurar barra - FORZAR CONFIGURACIÓN
	weight_bar.min_value = 1
	weight_bar.max_value = 5
	weight_bar.step = 1
	weight_bar.value = weight_component.get_current_level()
	
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
	
	var new_level = weight_component_ref.get_current_level()
	var old_value = weight_bar.value
	
	# Actualizar valor
	weight_bar.value = new_level
	
	# Actualizar etiqueta
	_update_weight_display(new_weight_value, new_level)
	
	# Forzar actualización visual
	weight_bar.queue_redraw()
	
	print("⚖️ Barra actualizada: ", old_value, " → ", weight_bar.value, " (", new_weight_value, "kg)")
	print("🔧 Estado barra después - Min: ", weight_bar.min_value, " Max: ", weight_bar.max_value, " Valor: ", weight_bar.value)

func _update_weight_display(weight_kg: float, level: int):
	if not weight_label:
		return
		
	var weight_names = ["", "LIGERO", "NORMAL", "MEDIO", "PESADO", "MUY PESADO"]
	var colors = [Color.WHITE, Color.CYAN, Color.GREEN, Color.YELLOW, Color.ORANGE, Color.RED]
	
	# Asegurarse de que el nivel esté dentro del rango válido
	level = clampi(level, 1, 5)
	
	# Actualizar texto y color del label
	weight_label.text = str(int(weight_kg)) + "kg (" + weight_names[level] + ")"
	weight_label.modulate = colors[level]
	
	# Actualizar color de la barra de progreso
	if weight_bar and level > 0:
		var style = StyleBoxFlat.new()
		style.bg_color = colors[level]
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_right = 4
		style.corner_radius_bottom_left = 4
		weight_bar.add_theme_stylebox_override("fill", style)
