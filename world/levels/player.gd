extends CharacterBody2D

# --- Variáveis de Movimento ---
@export var speed: float = 100.0
@export var acceleration: float = 1000.0
@export var friction: float = 1200.0

# --- Variáveis da Tocha ---
@export var light_drain_rate: float = 0.1 # O quão rápido a luz diminui por segundo
@onready var torch: PointLight2D = $PointLight2D # Pega a referência do nó da luz
@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		anim.play("walk")
		anim.flip_h = direction < 0
	else:
		anim.play("idle")
	
	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	move_and_slide()

func _process(delta: float) -> void:
	if torch.texture_scale > 0.2:
		torch.texture_scale -= light_drain_rate * delta

func refill_torch(amount: float) -> void:
	torch.texture_scale = clamp(torch.texture_scale + amount, 0.2, 9.99)
	# O 'clamp' garante que a luz não passe do tamanho máximo
