class_name WeightComponent
extends Node

signal weight_changed(value)

@export var weight: float = 50.0:
	set(value):
		var old_weight = weight
		weight = clamp(value, min_weight, max_weight)
		print("🔥 WeightComponent - Peso cambiado: ", old_weight, " → ", weight, "kg")
		weight_changed.emit(weight)

@export var min_weight: float = 10.0
@export var max_weight: float = 100.0

var weight_levels = [10.0, 25.0, 50.0, 75.0, 100.0]
var current_weight_index = 2  # Empezar en 50kg

func change_to_next_level():
	current_weight_index = (current_weight_index + 1) % weight_levels.size()
	weight = weight_levels[current_weight_index]
	print("✅ Siguiente nivel: índice ", current_weight_index, " = ", weight, "kg")

func change_to_previous_level():
	current_weight_index = (current_weight_index - 1 + weight_levels.size()) % weight_levels.size()
	weight = weight_levels[current_weight_index]
	print("✅ Nivel anterior: índice ", current_weight_index, " = ", weight, "kg")

func get_current_level() -> int:
	return current_weight_index + 1

func get_total_levels() -> int:
	return weight_levels.size()
