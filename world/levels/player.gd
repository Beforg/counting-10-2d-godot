extends CharacterBody2D

# --- Variáveis de Movimento ---
@export var speed: float = 100.0
@export var acceleration: float = 1000.0
@export var friction: float = 1200.0
@export var walk_speed: float = 75.0

var current_speed: float = 100.0
var adrenaline_timer: float = 0.0
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
	if adrenaline_timer > 0:
		adrenaline_timer -= delta
		if adrenaline_timer <= 0:
			speed = walk_speed # Volta ao normal quando o efeito acaba
			print("Efeito da Adrenalina passou.")

func refill_torch(amount: float) -> void:
	torch.texture_scale = clamp(torch.texture_scale + amount, 0.2, 9.99)
	# O 'clamp' garante que a luz não passe do tamanho máximo
func _input(event: InputEvent) -> void:
	# USAR ADRENALINA (Tecla Q)
	if event.is_action_pressed("usar_adrenalina"):
		if GameManager.try_use_adrenaline():
			# Aplicar o Boost de Velocidade com base no Vício
			if GameManager.is_addicted:
				speed = walk_speed * 1.2  # Bónus menor (20%)
				adrenaline_timer = 7.5           # Dura menos tempo
				print("Usou Adrenalina (Viciado): Velocidade 1.2x")
			else:
				speed = walk_speed * 3  # Bónus maior (60%)
				adrenaline_timer = 10.0          # Duração normal
				print("Usou Adrenalina: Velocidade 1.6x")

	# USAR REFIL DE TOCHA (Tecla F)
	if event.is_action_pressed("usar_tocha"):
		if GameManager.torch_refills > 0:
			GameManager.torch_refills -= 1
			torch.texture_scale = 1.5 # Reseta a luz para o máximo
			print("Tocha recarregada!")
