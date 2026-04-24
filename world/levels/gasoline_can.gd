extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Verifica se quem pisou foi o jogador (e não o monstro ou uma árvore)
	if body.name == "Player":
		
		# Avisa o cérebro global que pegamos 1 galão
		GameManager.collect_gasoline()
		
		# Destrói o item da tela
		queue_free()
