extends Area2D

@export var value: int = 10 # Quantos dólares essa nota vale

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.collect_dollar(value)
		queue_free()
