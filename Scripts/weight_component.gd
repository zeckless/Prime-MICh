class_name WeightComponent
extends Node

signal weight_changed(value)

@export var weight: float = 50.0:
	set(value):
		var old_weight = weight
		weight = clamp(value, min_weight, max_weight)
		print("🔥 WeightComponent - Peso cambiado: ", old_weight, " → ", weight, "kg")
		weight_changed.emit(weight)

@export var min_weight: float = 25.0  # Cambiado de 10.0 a 25.0
@export var max_weight: float = 100.0

var weight_levels = [25.0, 37.5, 50.0, 75.0, 100.0]  # Ajustado para empezar en 25kg
var current_weight_index = 2  # Empezar en 50kg

func change_to_next_level():
	# Verificar si ya estamos en el nivel máximo
	if current_weight_index >= weight_levels.size() - 1:
		print("❌ Ya estás en el peso máximo (", weight, "kg)")
		return
		
	current_weight_index += 1
	weight = weight_levels[current_weight_index]
	print("✅ Siguiente nivel: índice ", current_weight_index, " = ", weight, "kg")

func change_to_previous_level():
	# Verificar si ya estamos en el nivel mínimo
	if current_weight_index <= 0:
		print("❌ Ya estás en el peso mínimo (", weight, "kg)")
		return
		
	current_weight_index -= 1
	weight = weight_levels[current_weight_index]
	print("✅ Nivel anterior: índice ", current_weight_index, " = ", weight, "kg")

func get_current_level() -> int:
	return current_weight_index + 1

func get_total_levels() -> int:
	return weight_levels.size()
