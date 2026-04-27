extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if GameManager.gasoline_count >= 10:
			_victory()
		else:
			print("Você ainda não tem combustível suficiente!")

func _victory():
	print("VITÓRIA! Você escapou da floresta.")
	# Aqui você pode mudar para uma cena de créditos ou menu principal
	get_tree().change_scene_to_file("res://win_screen.tscn")
