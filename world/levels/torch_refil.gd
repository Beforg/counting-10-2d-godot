extends Area2D

@export var refill_amount: float = 1 # Quanto de "vida" a tocha ganha
func _ready() -> void:
	pass
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	print(">>> ALGO ENCOSTOU NO ITEM <<< Nome do corpo: ", body.name)
	
	if body.has_method("refill_torch"):
		print("O corpo tem a função refill_torch! Curando e deletando item...")
		body.refill_torch(refill_amount)
		GameManager.collect_torch_refill()
		var sound = body.get_node("CollectSound")
		if sound:
			sound.play()
		queue_free() 
	else:
		print("O corpo não tem a função refill_torch.")
