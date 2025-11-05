extends CanvasLayer

@onready var weight_bar: ProgressBar = $MarginContainer/ProgressBar
var weight_component_ref: WeightComponent = null

func _ready():
	print("✅ HUDpeso inicializado correctamente")
	# DIAGNÓSTICO COMPLETO
	print("🔍 DIAGNÓSTICO DE NODOS:")
	print(" - MarginContainer existe: ", $MarginContainer != null)
	if $MarginContainer:
		print(" - Hijos de MarginContainer:")
		for child in $MarginContainer.get_children():
			print("   - ", child.name, " (", child.get_class(), ")")
	
	print(" - weight_bar referencia: ", weight_bar != null)
	if weight_bar:
		print(" - weight_bar es ProgressBar: ", weight_bar is ProgressBar)
		print(" - weight_bar valor actual: ", weight_bar.value)
		print(" - weight_bar min/max: ", weight_bar.min_value, "/", weight_bar.max_value)

func setup_weight(weight_component: WeightComponent = null):
	print("🔄 Intentando configurar HUD de peso...")
	
	if weight_component == null:
		print("❌ Error: No se proporcionó WeightComponent")
		return false
	
	# VERIFICACIÓN EXHAUSTIVA DE LA BARRA
	print("🔍 VERIFICANDO BARRA DE PESO:")
	print(" - weight_bar existe: ", weight_bar != null)
	
	if not weight_bar:
		print("❌ BUSCANDO ALTERNATIVAS...")
		# Buscar manualmente la ProgressBar
		weight_bar = get_node_or_null("MarginContainer/ProgressBar")
		print(" - Búsqueda manual: ", weight_bar != null)
		
		if not weight_bar:
			print("❌ LISTANDO TODOS LOS NODOS:")
			_list_all_nodes(self, "")
			return false
	
	# Guardar referencia
	weight_component_ref = weight_component
	
	# CONFIGURAR BARRA CON VERIFICACIONES
	print("📊 CONFIGURANDO BARRA:")
	print(" - Antes - min:", weight_bar.min_value, " max:", weight_bar.max_value, " value:", weight_bar.value)
	
	weight_bar.min_value = 1
	weight_bar.max_value = 5
	var target_level = weight_component.get_current_level()
	weight_bar.value = target_level
	
	print(" - Después - min:", weight_bar.min_value, " max:", weight_bar.max_value, " value:", weight_bar.value)
	print(" - ¿Se aplicó el valor?", weight_bar.value == target_level)
	
	# Conectar señal
	if weight_component.weight_changed.is_connected(_on_weight_changed):
		weight_component.weight_changed.disconnect(_on_weight_changed)
		print("🔄 Señal anterior desconectada")
	
	var connection_result = weight_component.weight_changed.connect(_on_weight_changed)
	print("🔗 Conexión resultado: ", connection_result == OK)
	
	print("✅ HUD de peso configurado")
	return true

func _list_all_nodes(node: Node, indent: String):
	print(indent, "- ", node.name, " (", node.get_class(), ")")
	for child in node.get_children():
		_list_all_nodes(child, indent + "  ")

func _on_weight_changed(new_weight_value):
	print("🎯 ¡¡¡SEÑAL RECIBIDA!!! Valor: ", new_weight_value)
	
	if not weight_component_ref or not weight_bar:
		print("❌ Error: Referencias nulas")
		return
	
	var new_level = weight_component_ref.get_current_level()
	var old_value = weight_bar.value
	
	print("📊 ACTUALIZANDO BARRA:")
	print(" - Valor anterior: ", old_value)
	print(" - Valor objetivo: ", new_level)
	
	# MÚLTIPLES INTENTOS DE ACTUALIZACIÓN
	weight_bar.value = new_level
	print(" - Después de asignar: ", weight_bar.value)
	
	# Forzar redibujado
	weight_bar.queue_redraw()
	
	# Verificar resultado
	if weight_bar.value == new_level:
		print("✅ ¡BARRA ACTUALIZADA CORRECTAMENTE!")
	else:
		print("❌ ¡¡¡LA BARRA NO SE ACTUALIZÓ!!!")
		print("❌ Esperado: ", new_level, " | Actual: ", weight_bar.value)
		
		# FORZAR ACTUALIZACIÓN EXTREMA
		weight_bar.set_value_no_signal(new_level)
		print(" - Después de set_value_no_signal: ", weight_bar.value)
	
	print("📊 Estado final: ", weight_bar.value, "/", weight_bar.max_value)
