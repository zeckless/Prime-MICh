extends CanvasLayer

func _ready():
	get_tree().paused = true
	$CenterContainer/VBoxContainer/NextLevelButton.pressed.connect(_on_next_level_pressed)
	$CenterContainer/VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)

func _on_next_level_pressed():
	get_tree().paused = false
	# Limpiar la escena actual
	queue_free()
	# Aquí puedes cargar el siguiente nivel
	get_tree().change_scene_to_file("res://Scenes/mundo.tscn")

func _on_menu_pressed():
	get_tree().paused = false
	# Limpiar la escena actual
	queue_free()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")