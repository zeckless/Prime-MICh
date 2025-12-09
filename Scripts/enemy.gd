extends CharacterBody2D

const GRAVITY = 900
const SPEED = 40

@onready var animationPlayer = $AnimationPlayer
var direction = 1
var is_dead = false
var is_attacking = false
var esta_activo = false

func _ready():
	add_to_group("enemy")

func _physics_process(delta):
	if esta_activo == false:
		return
	if is_dead:
		velocity.x = 0
		return

	velocity.x = SPEED * direction

	# Cambia de dirección si choca con una pared
	if is_on_wall():
		direction *= -1
		velocity.x = SPEED * direction

	# Aplica gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	# Animación de caminar solo si no está atacando ni muerto
	if not is_attacking and not is_dead:
		if animationPlayer.current_animation != "walk":
			animationPlayer.play("walk")

	move_and_slide()

	# Detectar colisión con el jugador
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("player"):
			if has_method("attack") and not is_attacking and not collision.get_collider().is_dead:
				attack()
			# Usar sistema de daño gradual en lugar de muerte inmediata
			if collision.get_collider().has_method("take_damage") and not collision.get_collider().is_dead and not is_dead:
				collision.get_collider().take_damage(25.0)  # Mismo daño que el player tiene configurado

func die():
	if is_dead:
		return
	is_dead = true
	is_attacking = false
	set_collision_mask_value(1, false)
	animationPlayer.play("death")
	await animationPlayer.animation_finished
	queue_free()

func attack():
	if is_dead or is_attacking:
		return
	is_attacking = true
	animationPlayer.play("attack")
	await animationPlayer.animation_finished
	is_attacking = false


func _on_zona_activacion_body_entered(body: Node2D) -> void:
	if body.name == "player":
		esta_activo = true
		
