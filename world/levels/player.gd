extends CharacterBody2D

# --- Variáveis de Movimento ---
@export var speed: float = 75.00
@export var acceleration: float = 700.0
@export var friction: float = 1200.0
@export var walk_speed: float = 75.0 

var adrenaline_timer: float = 0.0

# --- Variáveis da Tocha ---
@export var light_drain_rate: float = 0.1 
@onready var torch: PointLight2D = $PointLight2D 
@onready var anim = $AnimatedSprite2D
@onready var step_sound = $StepSound
@onready var step_timer = $StepTimer
@onready var heart_low = $HeartbeatLow
@onready var heart_high = $HeartbeatHigh

func _ready() -> void:
	# Conecta o sinal do Diretor à nossa função local
	GameManager.difficulty_increased.connect(_on_difficulty_increased)

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# --- 1. LÓGICA DE ANIMAÇÃO ---
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
	
	# --- 2. LÓGICA DE CÁLCULO DE VELOCIDADE ---
	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# --- 3. LÓGICA DE SOM DOS PASSOS (CORRIGIDA) ---
	if velocity.length() > 0:
		# Se está andando e o timer terminou de contar
		if step_timer.is_stopped():
			step_sound.pitch_scale = randf_range(0.8, 1.2) 
			step_sound.play()
			step_timer.start() # Inicia o timer para o próximo passo
	else:
		# Se o jogador parar do nada, cancela o timer e corta o som na hora
		step_timer.stop()
		step_sound.stop()
	
	# --- 4. APLICAÇÃO DO MOVIMENTO ---
	print("Lendo Adrenalina: ", GameManager.is_adrenaline_active, " | Velocidade Alvo: ", speed, " | Vício: ", GameManager.is_addicted)
	move_and_slide()

func _process(delta: float) -> void:
	_update_heartbeat_audio()
	
	# Dreno da tocha
	if torch.texture_scale > 0.2:
		# Só drena se tiver pegado o primeiro galão
		if GameManager.gasoline_count > 0: 
			torch.texture_scale -= light_drain_rate * delta
		
	# --- GESTÃO DE VELOCIDADE (Aqui a mágica tem que acontecer) ---
	if GameManager.is_adrenaline_active:
		if GameManager.is_addicted:
			speed = walk_speed * 1.2 # Fica um pouco mais rápido (90)
		else:
			speed = walk_speed * 3.0 # Fica MUITO rápido (225)
	elif GameManager.terror_level >= 50.0:
		speed = walk_speed * 0.5 # Fica lento (37.5)
	else:
		speed = walk_speed # Normal (75)

func _input(event: InputEvent) -> void:
	# USAR CURA (Tecla configurada no Input Map)
	if event.is_action_pressed("usar_cura"):
		if GameManager.cures_count > 0:
			GameManager.cures_count -= 1
			GameManager.is_addicted = false # Remove o vício
			print("Você usou a cura! Estado normalizado.")
		else:
			print("Você não tem curas!")
	
	# USAR ADRENALINA (Tecla configurada no Input Map)
# USAR ADRENALINA (Tecla Q)
	if event.is_action_pressed("usar_adrenalina"):
		if GameManager.try_use_adrenaline():
			# Só reduz o terror. O _process ali em cima vai cuidar da velocidade!
			GameManager.terror_level = max(0.0, GameManager.terror_level - 30.0)
			print("PLAYER: Adrenalina injetada!")

	# USAR REFIL DE TOCHA (Tecla configurada no Input Map)
	if event.is_action_pressed("usar_tocha"):
		if GameManager.torch_refills > 0:
			GameManager.torch_refills -= 1
			torch.texture_scale = 8 
			print("Tocha recarregada!")

func refill_torch(amount: float) -> void:
	torch.texture_scale = clamp(torch.texture_scale + amount, 0.2, 9.99)

func _on_difficulty_increased(level: int) -> void:
	if level == 1:
		light_drain_rate = 0.15 # Gasta 50% mais rápido
		print("PLAYER: A tocha está falhando mais rápido (Nível 1)")
	elif level == 2:
		light_drain_rate = 0.25 # Gasta muito mais rápido!
		print("PLAYER: A tocha está derretendo! (Nível 2)")
		
func _update_heartbeat_audio():
	var level = GameManager.terror_level
	
	if level >= 60:
		# Terror Crítico: Toca o rápido, para o lento
		if not heart_high.playing:
			heart_high.play()
			heart_low.stop()
	elif level >= 30:
		# Terror Moderado: Toca o lento, para o rápido
		if not heart_low.playing:
			heart_low.play()
			heart_high.stop()
	else:
		# Seguro: Para tudo
		if heart_low.playing: heart_low.stop()
		if heart_high.playing: heart_high.stop()
