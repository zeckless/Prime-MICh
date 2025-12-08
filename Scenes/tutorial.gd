extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if  body.name == "player":
		call_deferred("cambiar_escena")
		
func cambiar_escena():
	get_tree().change_scene_to_file("res://Scenes/menu_fin_tutorial.tscn")
	
		
