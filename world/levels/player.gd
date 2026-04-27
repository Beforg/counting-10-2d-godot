extends CharacterBody2D

# --- Variáveis de Movimento ---
@export var speed: float = 75.00
@export var acceleration: float = 700.0
@export var friction: float = 1200.0

# Ajustei a walk_speed para 100.0 para ser a sua velocidade base oficial
@export var walk_speed: float = 75.0 

var adrenaline_timer: float = 0.0

# --- Variáveis da Tocha ---
@export var light_drain_rate: float = 0.1 
@onready var torch: PointLight2D = $PointLight2D 
@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_direction != Vector2.ZERO:
		if abs(input_direction.x) > abs(input_direction.y):
			# Movimento horizontal
			anim.play("walk")
			anim.flip_h = input_direction.x < 0
		else:
			# Movimento vertical
			if input_direction.y > 0:
				anim.play("down")
				anim.flip_h = input_direction.x < 0
			else:
				anim.play("top")
	else:
		anim.play("idle")
	
	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	move_and_slide()

func _process(delta: float) -> void:
	# 1. Dreno contínuo da Tocha
	if torch.texture_scale > 0.2:
		torch.texture_scale -= light_drain_rate * delta
		
	# 2. Timer da Adrenalina
	if adrenaline_timer > 0:
		adrenaline_timer -= delta
		if adrenaline_timer <= 0:
			print("Efeito da Adrenalina passou.")
			
	# --- NOVA LÓGICA: GESTÃO DE ESTADOS DE VELOCIDADE ---
	if adrenaline_timer > 0:
		# Se a adrenalina está ativa, o script mantém o boost definido lá no _input.
		pass 
	elif GameManager.terror_level >= 50.0:
		# ESTADO DE PÂNICO: Terror no máximo deixa o jogador 50% mais lento
		speed = walk_speed * 0.5
	else:
		# ESTADO NORMAL: Sem adrenalina e sem pânico
		speed = walk_speed

func refill_torch(amount: float) -> void:
	torch.texture_scale = clamp(torch.texture_scale + amount, 0.2, 9.99)

func _input(event: InputEvent) -> void:
	# USAR ADRENALINA (Tecla Q)
	if event.is_action_pressed("usar_adrenalina"):
		if GameManager.try_use_adrenaline():
			
			# --- NOVA LÓGICA: Adrenalina reduz o Terror em 30% na hora ---
			GameManager.terror_level = max(0.0, GameManager.terror_level - 30.0)
			
			if GameManager.is_addicted:
				speed = walk_speed * 1.2  # Bônus menor (20%)
				adrenaline_timer = 7.5    # Dura menos tempo
				print("Usou Adrenalina (Viciado): Velocidade 1.2x")
			else:
				speed = walk_speed * 3.0  # Fuga frenética!
				adrenaline_timer = 10.0   # Duração normal
				print("Usou Adrenalina: Velocidade 3.0x")

	# USAR REFIL DE TOCHA (Tecla F)
	if event.is_action_pressed("usar_tocha"):
		if GameManager.torch_refills > 0:
			GameManager.torch_refills -= 1
			torch.texture_scale = 1.5 
			print("Tocha recarregada!")
func _ready() -> void:
	# Conecta o sinal do Diretor à nossa função local
	GameManager.difficulty_increased.connect(_on_difficulty_increased)

func _on_difficulty_increased(level: int) -> void:
	if level == 1:
		light_drain_rate = 0.15 # Gasta 50% mais rápido
		print("PLAYER: A tocha está falhando mais rápido (Nível 1)")
	elif level == 2:
		light_drain_rate = 0.25 # Gasta muito mais rápido!
		print("PLAYER: A tocha está derretendo! (Nível 2)")
