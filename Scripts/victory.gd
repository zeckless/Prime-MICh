extends CanvasLayer

func _ready():
	get_tree().paused = true
	# Ocultar todos los HUDs cuando aparece la pantalla de victoria
	for hud in get_tree().get_nodes_in_group("hud"):
		hud.hide()
	
	$CenterContainer/VBoxContainer/CreditsButton.pressed.connect(_on_credits_pressed)
	$CenterContainer/VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)

func _on_credits_pressed():
	get_tree().paused = false
	# Limpiar la escena actual
	queue_free()
	# Aquí puedes cargar el siguiente nivel
	get_tree().change_scene_to_file("res://Scenes/creditos.tscn")

func _on_menu_pressed():
	get_tree().paused = false
	# Limpiar la escena actual
	queue_free()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
