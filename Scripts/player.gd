extends CharacterBody2D

# --- CONFIGURACIÓN DE MOVIMIENTO ---
const RUN_SPEED = 60.0
const RUN_MAX_SPEED = 120.0
const PUSHING_SPEED = 60.0 
const JUMP_HEIGHT = -300.0
const GRAVITY = 15.0

# --- CONFIGURACIÓN DEL DASH ---
const DASH_SPEED = 700.0  
const DASH_STOP_DISTANCE = 25.0 
const MIN_DASH_TIME = 0.5 

# --- CONFIGURACIÓN DEL REBOTE (NUEVO) ---
const RECOIL_SPEED = 400.0   # Velocidad hacia atrás
const RECOIL_JUMP = -250.0   # Un pequeño salto para el "airspin"
const RECOIL_DURATION = 0.4  # Cuánto tiempo dura el descontrol

# --- SISTEMA DE PESO ---
var current_weight = 37.0 
var weight_levels = [37.0, 50.0, 75.0, 100.0]
var current_weight_index = 0
var max_weight = 100.0

# --- INTERACCIÓN ---
var detection_radius = 400.0 
var nearby_objects = []
var selected_object = null

# --- ESTADOS ---
var is_dead = false
var facing_right = true
var is_pulling = false
var is_pushing = false
var is_dashing = false 
var is_recoiling = false # NUEVO ESTADO: Retrocediendo/Rebotando
var action_target = null 
var current_dash_timer = 0.0 
var current_recoil_timer = 0.0 # NUEVO TIMER

# --- REFERENCIAS ---
@onready var anim_sprite = $AnimatedSprite2D 
@onready var pause_menu_scene = preload("res://Scenes/pausa_menu.tscn")
@onready var hud: CanvasLayer = $HUD
@onready var hudpeso: CanvasLayer = $HUDpeso
@onready var health_component = $HealthComponent
@onready var weight_component = $WeightComponent

func _ready():
	add_to_group("player")
	setup_components()
	if not anim_sprite: print("🔴 ERROR: Falta AnimatedSprite2D")

func setup_components():
	if hud and health_component:
		hud.setup(health_component)
		health_component.died.connect(_on_died)
	
	if weight_component:
		weight_component.weight = weight_levels[current_weight_index]
		current_weight = weight_component.weight
		if hudpeso: hudpeso.setup_weight(weight_component)
	else:
		current_weight = weight_levels[current_weight_index]

func _process(_delta):
	if not is_dead:
		if Input.is_action_just_pressed("increase_weight"): change_weight_level()
		if Input.is_action_just_pressed("decrease_weight"): decrease_weight()

func _physics_process(delta):
	if is_dead: return

	# 1. LÓGICA DE REBOTE / RECOIL (NUEVA PRIORIDAD)
	if is_recoiling:
		process_recoil_physics(delta)
		move_and_slide()
		return # Cortamos aquí, el jugador no tiene control mientras rebota

	# 2. LÓGICA DE DASH
	if is_dashing:
		process_dash_physics(delta)
		move_and_slide()
		return 

	# 3. LÓGICA DE FUERZAS SOBRE OBJETOS
	if is_instance_valid(action_target):
		if is_pulling:
			process_object_pull(delta)
		elif is_pushing:
			process_object_push(delta)

	# 4. MOVIMIENTO JUGADOR
	detect_nearby_objects()
	apply_gravity()
	handle_movement_input() 
	
	move_and_slide()
	handle_collisions()
	
	# 5. ACTUALIZAR ANIMACIONES
	update_animations()

# ================================================================
# LÓGICA DE REBOTE / RECOIL (NUEVO)
# ================================================================
func process_recoil_physics(delta):
	# Contamos el tiempo
	current_recoil_timer += delta
	
	# Aplicamos gravedad durante el rebote para que caiga natural
	velocity.y += GRAVITY * delta * 50.0 # Gravedad un poco ajustada para que no flote
	
	# Si se acabó el tiempo, volvemos a la normalidad
	if current_recoil_timer > RECOIL_DURATION:
		stop_all_interactions()
		velocity.x = 0 # Frenamos el movimiento horizontal al caer
		print("✅ Rebote terminado")

# ================================================================
# LÓGICA DE DASH
# ================================================================
func process_dash_physics(delta):
	if not is_instance_valid(action_target):
		stop_all_interactions()
		return

	current_dash_timer += delta
	var direction = (action_target.global_position - global_position).normalized()
	var distance = global_position.distance_to(action_target.global_position)
	
	velocity = direction * DASH_SPEED
	
	if distance < DASH_STOP_DISTANCE and current_dash_timer > MIN_DASH_TIME:
		velocity = Vector2.ZERO
		stop_all_interactions()

# ================================================================
# FÍSICA DE OBJETOS
# ================================================================

func process_object_pull(_delta):
	var dist = global_position.distance_to(action_target.global_position)
	if dist < 30:
		action_target.linear_velocity = Vector2.ZERO
		stop_all_interactions()
		return
	
	var dir = (global_position - action_target.global_position).normalized()
	if action_target is RigidBody2D:
		action_target.sleeping = false 
		action_target.linear_velocity = Vector2(dir.x * 250.0, action_target.linear_velocity.y)

func process_object_push(_delta):
	var push_dir = 1.0 if facing_right else -1.0
	if action_target is RigidBody2D:
		var target_vel_x = push_dir * PUSHING_SPEED * 1.5 
		action_target.linear_velocity = Vector2(target_vel_x, action_target.linear_velocity.y)

# ================================================================
# MOVIMIENTO DEL JUGADOR
# ================================================================

func apply_gravity():
	var weight_gravity_modifier = 0.5 + (current_weight / 100.0)
	velocity.y += GRAVITY * weight_gravity_modifier

func handle_movement_input():
	var speed_to_use = RUN_SPEED
	var max_speed_to_use = RUN_MAX_SPEED
	
	if is_pushing:
		speed_to_use = PUSHING_SPEED
		max_speed_to_use = PUSHING_SPEED

	var weight_mod = 0.7 + (50.0 / current_weight * 0.3)
	var mod_speed = speed_to_use * weight_mod
	var mod_max = max_speed_to_use * weight_mod

	if Input.is_action_pressed("ui_right"):
		facing_right = true
		velocity.x = min(velocity.x + mod_speed, mod_max)
	elif Input.is_action_pressed("ui_left"):
		facing_right = false
		velocity.x = max(velocity.x - mod_speed, -mod_max)
	else:
		var lerp_weight = 0.5 if is_on_floor() else 0.01
		velocity.x = lerp(velocity.x, 0.0, lerp_weight)

	if is_on_floor() and Input.is_action_just_pressed("ui_accept") and not is_pushing and not is_pulling:
		var weight_jump_modifier = 0.8 + (50.0 / current_weight * 0.4)
		velocity.y = JUMP_HEIGHT * weight_jump_modifier
		if has_node("jumpsound"): $jumpsound.play()

	if anim_sprite and not is_dashing and not is_recoiling:
		anim_sprite.flip_h = not facing_right

# ================================================================
# ANIMACIONES
# ================================================================
func update_animations():
	# Bloqueos de animaciones especiales
	if is_dashing: return
	if is_recoiling: return # airspin ya se está reproduciendo

	var anim = "idle" 
	if is_dead:
		anim = "death"
	elif not is_on_floor():
		anim = "jump"
	elif is_pushing:
		anim = "push"
	elif is_pulling:
		anim = "pull"
	elif abs(velocity.x) > 5:
		anim = "run"
	else:
		anim = "idle"
	
	play_anim(anim)

func play_anim(anim_name):
	if anim_sprite and anim_sprite.sprite_frames.has_animation(anim_name):
		if anim_sprite.animation != anim_name:
			anim_sprite.play(anim_name)

# ================================================================
# INPUTS
# ================================================================

func _input(event):
	if not event is InputEventKey or is_dead: return
	
	if event.is_action_pressed("ui_cancel"):
		var pause_menu = pause_menu_scene.instantiate()
		get_tree().current_scene.add_child(pause_menu)
		get_tree().paused = true

	# TECLA F
	if event.is_action_pressed("interact"):
		start_pull_or_dash()
	elif event.is_action_released("interact"):
		stop_all_interactions()
	
	# TECLA G
	if event.is_action_pressed("push"):
		start_push()
	elif event.is_action_released("push"):
		stop_all_interactions()

func start_pull_or_dash():
	if is_pushing or not is_instance_valid(selected_object): return
	
	var obj_weight = selected_object.get_weight() if selected_object.has_method("get_weight") else 50.0
	action_target = selected_object
	
	if current_weight > obj_weight:
		if is_on_floor():
			is_pulling = true
		else:
			print("⚠️ Solo en suelo")
	else:
		is_dashing = true
		current_dash_timer = 0.0 
		play_anim("dash")
		print("🚀 DASH INICIADO")

func start_push():
	if is_pulling or is_dashing or is_recoiling or not is_on_floor() or not is_instance_valid(selected_object): return
	var obj_weight = selected_object.get_weight() if selected_object.has_method("get_weight") else 50.0
	action_target = selected_object
	
	# --- LÓGICA DE REBOTE (PUSH BACK) ---
	if current_weight <= obj_weight: 
		print("🔙 Objeto muy pesado -> ¡REBOTE!")
		start_recoil() # Llamamos a la nueva función
		return
	# ------------------------------------

	is_pushing = true

# NUEVA FUNCIÓN PARA INICIAR EL REBOTE
func start_recoil():
	is_recoiling = true
	current_recoil_timer = 0.0
	
	# Dirección opuesta al objeto
	var direction_to_obj = (action_target.global_position - global_position).normalized()
	var recoil_dir = -direction_to_obj.x 
	if recoil_dir == 0: recoil_dir = -1.0 if facing_right else 1.0
	
	# Aplicar física de rebote
	velocity = Vector2(sign(recoil_dir) * RECOIL_SPEED, RECOIL_JUMP)
	
	# --- CORRECCIÓN DE ANIMACIÓN ---
	# Verificamos si existe "airspin". Si no, usamos "jump" para que no se vea raro.
	if anim_sprite.sprite_frames.has_animation("airspin"):
		anim_sprite.play("airspin")
		print("🌪️ Reproduciendo airspin")
	else:
		anim_sprite.play("jump")
		print("⚠️ ALERTA: No existe la animación 'airspin'. Usando 'jump' por mientras.")

func stop_all_interactions():
	is_pulling = false
	is_pushing = false
	is_dashing = false
	is_recoiling = false # Reseteamos el estado
	action_target = null
	current_dash_timer = 0.0
	current_recoil_timer = 0.0

# ================================================================
# UTILIDADES
# ================================================================
# (El resto de las utilidades sigue igual, no hace falta cambiarlas)
# Solo asegúrate de copiar hasta el final del archivo anterior
func change_weight_level():
	if weight_component:
		weight_component.change_to_next_level()
		update_local_weight()
	else:
		current_weight_index = (current_weight_index + 1) % weight_levels.size()
		current_weight = weight_levels[current_weight_index]

func decrease_weight():
	if weight_component:
		weight_component.change_to_previous_level()
		update_local_weight()
	else:
		current_weight_index = (current_weight_index - 1 + weight_levels.size()) % weight_levels.size()
		current_weight = weight_levels[current_weight_index]

func update_local_weight():
	current_weight = weight_component.weight
	current_weight_index = weight_component.current_weight_index
	if hudpeso: hudpeso.setup_weight(weight_component)

func detect_nearby_objects():
	nearby_objects.clear()
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var circle = CircleShape2D.new()
	circle.radius = detection_radius
	query.shape = circle
	query.transform = global_transform
	query.collision_mask = 1 
	var results = space_state.intersect_shape(query)
	var closest_dist = INF
	selected_object = null
	for result in results:
		var body = result["collider"]
		if body.is_in_group("interactable") and body != self:
			var dist = global_position.distance_to(body.global_position)
			if dist < closest_dist:
				closest_dist = dist
				selected_object = body

func handle_collisions():
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		if col.get_collider().is_in_group("enemy"):
			if col.get_normal().y < -0.7:
				velocity.y = JUMP_HEIGHT * 0.7
				if col.get_collider().has_method("die"): col.get_collider().die()
				else: col.get_collider().queue_free()
				if has_node("enemydeathsound"): $enemydeathsound.play()
			else:
				take_damage(25.0)

func take_damage(amount):
	if health_component:
		health_component.health -= amount
		if is_instance_valid(anim_sprite):
			var tw = create_tween()
			tw.tween_property(anim_sprite, "modulate", Color(1,0.5,0.5), 0.1)
			tw.tween_property(anim_sprite, "modulate", Color.WHITE, 0.1)

func _on_died():
	is_dead = true
	velocity = Vector2.ZERO
	if has_node("deathsound"): $deathsound.play()
	play_anim("death")
	await get_tree().create_timer(1.0).timeout
	get_tree().call_deferred("reload_current_scene")
