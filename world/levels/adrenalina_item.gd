extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var sound = body.get_node("CollectSound")
		if sound:
			sound.play()
		GameManager.collect_adrenaline()
		queue_free()
