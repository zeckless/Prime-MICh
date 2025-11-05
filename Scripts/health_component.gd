class_name HealthComponent
extends Node

signal health_changed(value)
signal died

var _health: int = 100  # Variable interna privada

@export var health: int = 100:
	set(value):
		var old_health = _health
		_health = clamp(value, 0, max_health)
		if _health != old_health:
			print("❤️ Vida cambiada: ", _health, "/", max_health)
			health_changed.emit(_health)
		if _health == 0:
			print("💀 Jugador ha muerto")
			died.emit()
	get:
		return _health

@export var max_health: int = 100

func _ready():
	_health = health  # Sincronizar valor inicial
	print("❤️ HealthComponent inicializado con vida: ", _health, "/", max_health)
