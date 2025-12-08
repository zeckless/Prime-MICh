extends Control

func _on_btn_nivel_1_pressed():
	get_tree().change_scene_to_file("res://Scenes/mundo.tscn")

func _on_btn_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	
func _on_btn_salir_pressed():
	get_tree().quit()
		
