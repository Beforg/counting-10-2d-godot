extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Chama a função que já criamos no nosso Cérebro!
		GameManager.cure_addiction()
		print("Pegou a Cura! Vício zerado.")
		queue_free()
