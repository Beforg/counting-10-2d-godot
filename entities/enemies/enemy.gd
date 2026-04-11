extends CharacterBody2D

@export var base_speed: float = 100.0
@export var player: Node2D # A variável que vai guardar "quem" é a presa

func _physics_process(delta: float) -> void:
	if player != null:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * base_speed
		move_and_slide()
