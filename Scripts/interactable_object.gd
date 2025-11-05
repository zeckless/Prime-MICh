extends RigidBody2D
class_name InteractableObject

@export var object_weight: float = 15.0  
@export var max_force_multiplier: float = 3.0  # Muy reducido para movimiento suave

func _ready():
	add_to_group("interactable")
	# Configurar el objeto como RigidBody2D
	gravity_scale = 1.0
	mass = object_weight / 50.0  # Masa MUY pequeña (era /20, ahora /50)
	
	# Asegurar que el objeto no esté congelado
	freeze = false
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	
	print("Objeto interactuable inicializado - Peso: ", object_weight, " Mass: ", mass)

func get_weight() -> float:
	return object_weight

func apply_interaction_force(force: Vector2):
	# Sistema SUAVE: movimiento gradual, no explosivo
	var force_magnitude = force.length()
	var max_allowed_force = object_weight * max_force_multiplier * 2  # Muy limitado
	
	var final_force = force
	if force_magnitude > max_allowed_force:
		# Limitar mucho para movimiento suave
		final_force = force.normalized() * max_allowed_force
		print("Fuerza limitada de ", force_magnitude, " a ", max_allowed_force)
	
	print("=== MOVIMIENTO SUAVE ===")
	print("Fuerza aplicada suavemente: ", final_force.length())
	
	apply_central_impulse(final_force)
	
	print("¡Impulso suave aplicado!")
	print("========================")
