extends CharacterBody2D

const runSpeed = 60
const runMaxSpeed = 120
const jumpHeight = -300
const gravity = 15

# Sistema de peso dinámico mejorado
var current_weight = 37.0  # Empezar con 37kg
var weight_levels = [37.0, 50.0, 75.0, 100.0]  # Niveles de peso actualizados
var current_weight_index = 0  # Índice actual en weight_levels (0 = 37kg)
var min_weight = 37.0      # Peso mínimo actualizado
var max_weight = 100.0     # Peso máximo
var weight_change_speed = 10.0  # Velocidad de cambio de peso

# Detección de objetos
var detection_radius = 100.0
var nearby_objects = []
var selected_object = null
var interaction_cooldown = 0.0  # Cooldown para evitar spam de interacción
var cooldown_time = 0.5  # Medio segundo entre interacciones

@onready var sprite = $Sprite2D2  
@onready var animationPlayer = $AnimationPlayer
@onready var pause_menu_scene = preload("res://Scenes/pausa_menu.tscn")

# NUEVO SISTEMA DEL PROFESOR - AGREGAR WEIGHT COMPONENT
@onready var hud: CanvasLayer = $HUD
@onready var hudpeso: CanvasLayer = $HUDpeso
@onready var health_component: HealthComponent = $HealthComponent
@onready var weight_component: WeightComponent = $WeightComponent

var is_dead = false
var facing_right = true  # Variable para recordar la dirección
var is_pulling = false   # Nueva variable para saber si está tirando
var is_pushing = false   # Nueva variable para saber si está empujando
var pull_target = null   # Objeto que estamos tirando
var push_target = null   # Objeto que estamos empujando
var pull_timer = 0.0     # Tiempo que llevamos tirando
var push_timer = 0.0     # Tiempo que llevamos empujando
var pull_duration = 2.0  # Duración total del tirón
var push_duration = 2.0  # Duración total del empuje

func _ready():
	add_to_group("player")
	
	# CONFIGURAR EL SISTEMA DEL PROFESOR
	if hud and health_component:
		hud.setup(health_component)
		print("✅ Sistema de vida configurado")
		
		# Conectar señal de muerte
		health_component.died.connect(_on_died)
		print("✅ Señal de muerte conectada")
	else:
		print("❌ ERROR: HUD o HealthComponent no encontrado")
		if not hud:
			print("  - HUD no encontrado")
		if not health_component:
			print("  - HealthComponent no encontrado")
	
	# CONFIGURAR COMPONENTE DE PESO
	if weight_component:
		# Inicializar con el peso correcto
		weight_component.weight = weight_levels[current_weight_index]
		current_weight = weight_component.weight
		print("✅ Componente de peso configurado: ", current_weight, "kg")
		
		# CONFIGURAR HUD DE PESO DIRECTAMENTE
		if hudpeso:
			# Llamar directamente sin await
			hudpeso.setup_weight(weight_component)
			print("✅ HUD de peso configurado")
		else:
			print("❌ Error: HUDpeso no encontrado")
	else:
		print("⚠️ WeightComponent no encontrado, usando sistema local")
	
	# Inicializar sistemas
	current_weight = weight_levels[current_weight_index]  # Empezar con el primer nivel de peso
	
	# Debug: verificar que el sprite está conectado
	if sprite:
		print("Sprite encontrado: ", sprite.name)
	else:
		print("ERROR: Sprite no encontrado!")
		print("Nodos hijos disponibles:")
		for child in get_children():
			print(" - ", child.name, " (", child.get_class(), ")")
	
	# Debug: verificar animaciones disponibles
	if animationPlayer:
		print("AnimationPlayer encontrado")
		print("Animaciones disponibles:")
		for anim_name in animationPlayer.get_animation_list():
			print(" - ", anim_name)
	else:
		print("ERROR: AnimationPlayer no encontrado!")

func _process(delta):
	# Manejar cambio de peso con E (just_pressed)
	if Input.is_action_just_pressed("increase_weight") and not is_dead:
		change_weight_level()
	
	# Procesar la interacción gradual si estamos tirando o empujando
	if is_pulling and pull_target:
		process_gradual_pull(delta)
	elif is_pushing and push_target:
		process_gradual_push(delta)
	
	# Reducir el cooldown
	if interaction_cooldown > 0:
		interaction_cooldown -= delta

# NUEVA FUNCIÓN PARA TOMAR DAÑO (SISTEMA DEL PROFESOR)
func take_damage(damage_amount):
	if health_component:
		# Usar el componente para aplicar el daño
		var old_health = health_component.health
		health_component.health -= damage_amount
		print("¡Daño recibido! Vida: ", old_health, " → ", health_component.health)
		
		if health_component.health > 0:
			# Efecto visual de daño
			flash_damage_effect()
	else:
		print("❌ ERROR: HealthComponent no encontrado")

# FUNCIÓN LLAMADA CUANDO EL COMPONENTE EMITE LA SEÑAL DE MUERTE
func _on_died():
	is_dead = true
	var game_over_scene = preload("res://Scenes/game_over.tscn").instantiate()
	add_child(game_over_scene)
	die()

func flash_damage_effect():
	# Efecto visual simple de parpadeo al recibir daño
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(1, 0.5, 0.5, 1), 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func change_weight_level():
	print("🔄 Cambiando peso nivel (E presionado)...")
	if weight_component:
		print("📊 Peso ANTES del cambio: ", weight_component.weight, "kg (nivel ", weight_component.get_current_level(), ")")
		weight_component.change_to_next_level()
		current_weight = weight_component.weight
		current_weight_index = weight_component.current_weight_index
		print("📊 Peso DESPUÉS del cambio: ", current_weight, "kg (nivel ", weight_component.get_current_level(), ")")
	else:
		current_weight_index = (current_weight_index + 1) % weight_levels.size()
		current_weight = weight_levels[current_weight_index]
		print("✅ Peso cambiado localmente a: ", current_weight, "kg")

func decrease_weight():
	print("🔄 Disminuyendo peso nivel (Q presionado)...")
	if weight_component:
		print("📊 Peso ANTES del cambio: ", weight_component.weight, "kg (nivel ", weight_component.get_current_level(), ")")
		weight_component.change_to_previous_level()
		current_weight = weight_component.weight
		current_weight_index = weight_component.current_weight_index
		print("📊 Peso DESPUÉS del cambio: ", current_weight, "kg (nivel ", weight_component.get_current_level(), ")")
	else:
		current_weight_index = (current_weight_index - 1 + weight_levels.size()) % weight_levels.size()
		current_weight = weight_levels[current_weight_index]
		print("✅ Peso disminuido localmente a: ", current_weight, "kg")

func _input(event):
	# Filtrar solo eventos de teclas para evitar problemas con mouse motion
	if not event is InputEventKey:
		return
	
	if event.is_action_pressed("ui_cancel") and not is_dead:
		if not get_tree().paused:
			var pause_menu = pause_menu_scene.instantiate()
			get_tree().current_scene.add_child(pause_menu)
			get_tree().paused = true
	
	# Control de peso con Q (solo presionado una vez)
	if event.is_action_pressed("decrease_weight") and not is_dead:
		decrease_weight()
	
	# Interacción con F (PULL)
	if event.is_action_pressed("interact"):
		# Si está empujando, detener push primero
		if is_pushing:
			stop_push_interaction()
		start_pull_interaction()
	elif event.is_action_released("interact"):
		stop_pull_interaction()
	
	# Interacción con G (PUSH)
	if event.is_action_pressed("push"):
		# Si está tirando, detener pull primero
		if is_pulling:
			stop_pull_interaction()
		start_push_interaction()
	elif event.is_action_released("push"):
		stop_push_interaction()

func start_pull_interaction():
	# Evitar conflictos: no permitir pull si ya está haciendo push
	if is_pushing:
		return
	
	# VERIFICAR QUE EL JUGADOR ESTÉ EN EL SUELO para poder tirar
	if not is_on_floor():
		print("No puedes tirar objetos mientras estás en el aire")
		return
		
	if not selected_object:
		print("No hay objeto cerca para PULL")
		return
	
	if not selected_object.has_method("get_weight"):
		print("El objeto no tiene peso definido")
		return
	
	var object_weight = selected_object.get_weight()
	print("¡INICIANDO PULL! Peso jugador: ", current_weight, " vs Peso objeto: ", object_weight)
	
	# Verificar si el jugador tiene suficiente peso
	if current_weight <= object_weight:
		print("El objeto es demasiado pesado para tirar de él")
		return
		
	pull_target = selected_object
	start_pulling_animation()

func start_push_interaction():
	# Evitar conflictos: no permitir push si ya está haciendo pull
	if is_pulling:
		return
	
	# VERIFICAR QUE EL JUGADOR ESTÉ EN EL SUELO para poder empujar
	if not is_on_floor():
		print("No puedes empujar objetos mientras estás en el aire")
		return
		
	if not selected_object:
		print("No hay objeto cerca para PUSH")
		return
	
	if not selected_object.has_method("get_weight"):
		print("El objeto no tiene peso definido")
		return
	
	var object_weight = selected_object.get_weight()
	print("¡INICIANDO PUSH! Peso jugador: ", current_weight, " vs Peso objeto: ", object_weight)
	
	# Verificar si el jugador tiene suficiente peso
	if current_weight <= object_weight:
		print("El objeto es demasiado pesado para empujar")
		return
		
	push_target = selected_object
	start_pushing_animation()

func stop_pull_interaction():
	if is_pulling:
		print("Deteniendo interacción de PULL por soltar F")
		stop_pulling_animation()

func stop_push_interaction():
	if is_pushing:
		print("Deteniendo interacción de PUSH por soltar G")
		stop_pushing_animation()

func increase_weight():
	current_weight = min(current_weight + weight_change_speed, max_weight)
	sync_weight_index()
	print("Peso aumentado a: ", current_weight)

func sync_weight_index():
	var closest_index = 0
	var closest_distance = abs(current_weight - weight_levels[0])
	
	for i in range(weight_levels.size()):
		var distance = abs(current_weight - weight_levels[i])
		if distance < closest_distance:
			closest_distance = distance
			closest_index = i
	
	current_weight_index = closest_index

func detect_nearby_objects():
	nearby_objects.clear()
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = detection_radius
	query.shape = circle_shape
	query.transform = global_transform
	query.collision_mask = 1
	
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var body = result["collider"]
		if body.is_in_group("interactable") and body != self:
			nearby_objects.append(body)
	
	if nearby_objects.size() > 0:
		var closest_object = null
		var closest_distance = INF
		
		for obj in nearby_objects:
			var distance = global_position.distance_to(obj.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_object = obj
		
		selected_object = closest_object
	else:
		selected_object = null

func process_gradual_pull(delta):
	if not pull_target or not pull_target.has_method("apply_interaction_force"):
		stop_pulling_animation()
		return
	
	if not is_on_floor():
		print("Pull interrumpido: jugador ya no está en el suelo")
		stop_pulling_animation()
		return
	
	pull_timer += delta
	
	if animationPlayer.current_animation != "pull":
		if animationPlayer.has_animation("pull"):
			animationPlayer.play("pull")
			print("Forzando animación pull (se había perdido)")
	
	var distance_to_object = global_position.distance_to(pull_target.global_position)
	
	if distance_to_object < 30:
		print("Objeto muy cerca (", distance_to_object, "), deteniendo pull")
		stop_pulling_animation()
		return
	
	var progress = min(pull_timer / pull_duration, 1.0)
	var force_multiplier = progress * 0.4
	var direction = (global_position - pull_target.global_position).normalized()
	var weight_difference = current_weight - pull_target.get_weight()
	var base_force = max(weight_difference * 1.5, 0.8)
	var final_force = base_force * force_multiplier
	
	if int(pull_timer * 15) % 3 == 0:
		print("Pull gradual - Distancia: ", int(distance_to_object), " | Fuerza: ", final_force)
		pull_target.apply_interaction_force(direction * final_force)

func start_pulling_animation():
	is_pulling = true
	pull_timer = 0.0
	if animationPlayer.has_animation("pull"):
		animationPlayer.play("pull")
		print("Iniciando animación pull")
	else:
		print("Animación 'pull' no encontrada")

func stop_pulling_animation():
	is_pulling = false
	pull_target = null
	pull_timer = 0.0
	if is_on_floor() and abs(velocity.x) < 10:
		if animationPlayer.has_animation("idle"):
			animationPlayer.play("idle")
	print("Terminando animación pull")

func start_pushing_animation():
	is_pushing = true
	push_timer = 0.0
	if animationPlayer.has_animation("push"):
		animationPlayer.play("push")
		print("Reproduciendo animación push")
	else:
		print("Animación 'push' no encontrada")

func stop_pushing_animation():
	is_pushing = false
	
	if push_target:
		if push_target.has_method("set_linear_velocity"):
			push_target.set_linear_velocity(Vector2.ZERO)
		if push_target.has_method("set_angular_velocity"):
			push_target.set_angular_velocity(0.0)
		
		print("Objeto detenido completamente al terminar push")
	
	push_target = null
	push_timer = 0.0
	
	if abs(velocity.x) <= 40:
		velocity.x = lerp(velocity.x, 0.0, 0.3)
	
	print("Push terminado - Objeto detenido, jugador desacelera gradualmente")

func process_gradual_push(delta):
	if not push_target or not is_pushing:
		return
	
	if not is_on_floor():
		print("Push interrumpido: jugador ya no está en el suelo")
		stop_pushing_animation()
		return
	
	push_timer += delta
	var progress = push_timer / push_duration
	
	if progress >= 1.0:
		print("Empuje completado")
		stop_pushing_animation()
		return
	
	if animationPlayer.current_animation != "push":
		if animationPlayer.has_animation("push"):
			animationPlayer.play("push")
			print("Forzando animación push (se había perdido)")
	
	var direction = (push_target.global_position - global_position).normalized()
	var horizontal_direction = Vector2(direction.x, 0).normalized()
	var distance_to_object = global_position.distance_to(push_target.global_position)
	var base_push_speed = 35.0  
	var push_speed = base_push_speed * (progress * 0.6 + 0.4)
	
	if horizontal_direction.x > 0:
		velocity.x = push_speed
		facing_right = true
	elif horizontal_direction.x < 0:
		velocity.x = -push_speed
		facing_right = false
	
	var object_speed = push_speed * 0.9
	var object_movement = Vector2(horizontal_direction.x * object_speed * delta, 0)
	
	push_target.global_position += object_movement
	
	if push_target.has_method("apply_central_impulse"):
		var tiny_force = Vector2(horizontal_direction.x * object_speed * 0.02, 0)
		push_target.apply_central_impulse(tiny_force)
	
	if sprite:
		sprite.flip_h = not facing_right
	
	print("Push híbrido - Jugador: ", push_speed, " | Objeto: ", object_speed, " | Dist: ", int(distance_to_object))
	
	var ideal_distance = 45.0
	if distance_to_object > ideal_distance + 20:
		var ideal_pos = Vector2(push_target.global_position.x - (horizontal_direction.x * ideal_distance), global_position.y)
		global_position = global_position.lerp(ideal_pos, 0.1)
		print("Reajuste suave horizontal - jugador muy lejos")

func attract_player_to_object(obj, _distance):
	var direction = (obj.global_position - global_position).normalized()
	var weight_difference = obj.get_weight() - current_weight
	var weight_ratio = obj.get_weight() / current_weight
	var base_force = weight_difference * 8
	var bonus_force = (weight_ratio - 1.0) * 15
	var total_force = base_force + bonus_force
	total_force = min(total_force, 300)
	
	print("Debug (atraído): Objeto peso: ", obj.get_weight(), " vs Tu peso: ", current_weight)
	print("Fuerza calculada: ", base_force + bonus_force, " → Limitada a: ", total_force)
	
	velocity += direction * total_force
	print("¡Siendo atraído hacia el objeto! Fuerza controlada: ", total_force)

func push_both(obj, _distance):
	var direction_to_object = (obj.global_position - global_position).normalized()
	var force_strength = 30.0
	
	if obj.has_method("apply_interaction_force"):
		obj.apply_interaction_force(direction_to_object * force_strength)
	
	velocity += -direction_to_object * force_strength
	print("Empuje mutuo - pesos iguales")

func attract_object(obj, _distance):
	if obj.has_method("apply_interaction_force"):
		var direction = (global_position - obj.global_position).normalized()
		var weight_difference = current_weight - obj.get_weight()
		var gentle_force = weight_difference * 8
		gentle_force = min(gentle_force, 300)
		
		print("Debug: Tu peso: ", current_weight, " vs Objeto: ", obj.get_weight())
		print("Diferencia: ", weight_difference, " → Fuerza suave: ", gentle_force)
		
		obj.apply_interaction_force(direction * gentle_force)
		print("Atrayendo objeto SUAVEMENTE con fuerza: ", gentle_force)

func push_object(obj, _distance):
	if obj.has_method("apply_interaction_force"):
		var direction = (obj.global_position - global_position).normalized()
		var force_strength = (obj.get_weight() - current_weight + 100) * 50
		obj.apply_interaction_force(direction * force_strength)
		print("Empujando objeto con fuerza: ", force_strength)

func _physics_process(_delta):
	if is_dead:
		return
	
	if interaction_cooldown > 0:
		interaction_cooldown -= _delta
	
	if is_pulling and pull_target:
		process_gradual_pull(_delta)
	
	detect_nearby_objects()
	
	var weight_gravity_modifier = 0.5 + (current_weight / 100.0)
	velocity.y += gravity * weight_gravity_modifier
	
	var friction = false
	var weight_speed_modifier = 0.7 + (50.0 / current_weight * 0.3)
	var modified_run_speed = runSpeed * weight_speed_modifier
	var modified_max_speed = runMaxSpeed * weight_speed_modifier
	
	if Input.is_action_pressed("ui_right") and not is_pushing:
		facing_right = true
		if is_on_floor() and not is_pulling and not is_pushing:
			if animationPlayer.current_animation != "run":
				animationPlayer.play("run")
		velocity.x = min(velocity.x + modified_run_speed, modified_max_speed)

	elif Input.is_action_pressed("ui_left") and not is_pushing:
		facing_right = false
		if is_on_floor() and not is_pulling and not is_pushing:
			if animationPlayer.current_animation != "run":
				animationPlayer.play("run")
		velocity.x = max(velocity.x - modified_run_speed, -modified_max_speed)

	else:
		if is_on_floor() and not is_pulling and not is_pushing:
			if animationPlayer.has_animation("idle"):
				animationPlayer.play("idle")
			else:
				animationPlayer.play("run")
				animationPlayer.seek(0.0)
				animationPlayer.pause()
		friction = true

	if not is_on_floor():
		if animationPlayer.current_animation != "jump":
			animationPlayer.play("jump")
		if friction:
			velocity.x = lerp(velocity.x, 0.0, 0.01)
	else:
		if Input.is_action_just_pressed("ui_accept") and not is_pulling and not is_pushing:
			var weight_jump_modifier = 0.8 + (50.0 / current_weight * 0.4)
			velocity.y = jumpHeight * weight_jump_modifier
			$jumpsound.play()
		if friction:
			velocity.x = lerp(velocity.x, 0.0, 0.5)

	move_and_slide()
	
	sprite.flip_h = not facing_right
	
	# Detectar colisión con enemigos
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("enemy"):
			var normal = collision.get_normal()
			
			if normal.y < -0.7:
				# Saltar sobre el enemigo (aplastarlo)
				velocity.y = jumpHeight * 0.7
				if collision.get_collider().has_method("die"):
					collision.get_collider().die()
				else:
					collision.get_collider().queue_free()
				$enemydeathsound.play()
				print("¡Enemigo aplastado!")
			else:
				# USAR EL NUEVO SISTEMA DE DAÑO
				if not is_dead:
					take_damage(25.0)  # Usar daño fijo de 25
					if collision.get_collider().has_method("attack"):
						collision.get_collider().attack()

func die():
	if is_dead:
		return
		
	is_dead = true
	velocity.x = 0
	velocity.y = 0
	$deathsound.play()
	animationPlayer.play("death")
	
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
