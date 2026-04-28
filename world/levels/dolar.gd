extends Area2D

@export var value: int = 10 # Quantos dólares essa nota vale

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var sound = body.get_node("CollectSound")
		if sound:
			sound.play()
		GameManager.collect_dollar(value)
		queue_free()
