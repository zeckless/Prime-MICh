extends Node2D

var ending = false

func _ready():
	# Crear algunos objetos de prueba para el sistema de peso
	create_test_objects()

func create_test_objects():
	# Crear objetos de diferentes pesos para probar el sistema
	var object_scene = preload("res://Scripts/interactable_object.gd")
	
	# Objeto ligero (peso 15) - MÁS LIGERO QUE EL JUGADOR
	var light_object = RigidBody2D.new()
	light_object.set_script(object_scene)
	light_object.object_weight = 15.0
	light_object.position = Vector2(200, 300)
	add_child(light_object)
	
	# Agregar sprite visual simple para el objeto ligero
	var light_sprite = ColorRect.new()
	light_sprite.size = Vector2(30, 30)
	light_sprite.color = Color.YELLOW  # Amarillo = ligero
	light_sprite.position = Vector2(-15, -15)
	light_object.add_child(light_sprite)
	
	# Agregar colisión
	var light_collision = CollisionShape2D.new()
	var light_shape = RectangleShape2D.new()
	light_shape.size = Vector2(30, 30)
	light_collision.shape = light_shape
	light_object.add_child(light_collision)
	
	# Objeto pesado (peso 80) - MÁS PESADO QUE EL JUGADOR
	var heavy_object = RigidBody2D.new()
	heavy_object.set_script(object_scene)
	heavy_object.object_weight = 80.0
	heavy_object.position = Vector2(400, 300)
	add_child(heavy_object)
	
	# Agregar sprite visual simple para el objeto pesado
	var heavy_sprite = ColorRect.new()
	heavy_sprite.size = Vector2(50, 50)
	heavy_sprite.color = Color.RED  # Rojo = pesado
	heavy_sprite.position = Vector2(-25, -25)
	heavy_object.add_child(heavy_sprite)
	
	# Agregar colisión
	var heavy_collision = CollisionShape2D.new()
	var heavy_shape = RectangleShape2D.new()
	heavy_shape.size = Vector2(50, 50)
	heavy_collision.shape = heavy_shape
	heavy_object.add_child(heavy_collision)
	
	print("Objetos de prueba creados:")
	print("- Objeto amarillo (peso 15): Tú lo atraes")
	print("- Objeto rojo (peso 80): Él te atrae a ti")

func _process(_delta):
	# Removida la transición automática a créditos
	pass
