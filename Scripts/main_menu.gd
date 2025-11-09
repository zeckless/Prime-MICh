extends Control

func _on_button_pressed():
	# Botón Jugar
	get_tree().change_scene_to_file("res://Scenes/mundo.tscn")

func _on_button_2_pressed():
	# Botón Créditos
	get_tree().change_scene_to_file("res://Scenes/creditos.tscn") 

func _on_button_3_pressed():
	# Botón Salir
	get_tree().quit()
