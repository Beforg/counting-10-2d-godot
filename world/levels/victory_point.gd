extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if GameManager.gasoline_count >= 10:
			win_game()
		else:
			print("Você ainda não tem combustível suficiente!")

func win_game():
	print("VOCÊ ESCAPOU!")
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://win_screen.tscn")
