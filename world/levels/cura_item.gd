extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var sound = body.get_node("CollectSound")
		if sound:
			sound.play()
		# Chama a função que já criamos no nosso Cérebro!
		GameManager.collect_cure()
		print("Pegou a Cura!")
		queue_free()
