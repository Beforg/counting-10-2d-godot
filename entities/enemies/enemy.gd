extends CharacterBody2D

enum State { HIDDEN, STALKING, HUNTING }
var current_state: State = State.HIDDEN
var is_active: bool = false # Começa dormindo
@onready var anim = $AnimatedSprite2D
@export var stalk_speed: float = 75.0
@export var hunt_speed: float = 165.0
@export var base_light_radius: float = 25.0
@onready var terror_aura = $TerrorAura
@export var player: Node2D

func _physics_process(delta: float) -> void:
	if not is_active:
		anim.play("idle")
		return
		
	if player != null and player.get("torch") != null:
		var light = player.torch.texture_scale
		var distance = global_position.distance_to(player.global_position)
		
		# Calculamos onde termina a luz (80% para ele ficar na penumbra escura)
		var current_safe_zone = base_light_radius * light * 0.8
		
		if light > 5:
			current_state = State.HIDDEN
		elif light > 3: # Enquanto houver o mínimo de luz, ele tem medo
			current_state = State.STALKING
		else:
			current_state = State.HUNTING
			current_safe_zone = 0.0 # Luz apagou de vez, ele perde o medo!
			
		# --- A AÇÃO ---
		match current_state:
			
			State.HIDDEN:
				visible = false
				velocity = Vector2.ZERO
				move_and_slide()
				
			State.STALKING:
				visible = true
				var dir = global_position.direction_to(player.global_position)
				
				# Respeita a parede de luz
				if distance > current_safe_zone:
					# Está no escuro, anda na sua direção
					velocity = dir * stalk_speed
				elif distance < current_safe_zone - 10.0:
					# Jogador andou pra cima dele: recua assustado para as sombras
					velocity = -dir * (stalk_speed * 0.8)
				else:
					# Exatamente na borda: Fica parado te observando
					velocity = Vector2.ZERO 
				
				move_and_slide()
				
			State.HUNTING:
				visible = true
				
				# O BOTE
				if distance > 400.0:
					teleport_near_player(current_safe_zone)
				
				# Corre pra matar
				if distance > 25.0:
					var dir = global_position.direction_to(player.global_position)
					velocity = dir * hunt_speed
					move_and_slide()
				else:
					GameManager.reset_game()
					get_tree().reload_current_scene() # Game Over
	if velocity.length() > 0:
		# Verifica qual eixo tem o movimento mais forte (X ou Y)
		if abs(velocity.x) > abs(velocity.y):
			# MOVIMENTO HORIZONTAL
			anim.play("walk_side")
			anim.flip_h = velocity.x < 0 # Vira para a esquerda se o X for negativo
		else:
			# MOVIMENTO VERTICAL
			if velocity.y > 0:
				anim.play("walk_down") # Y positivo desce na tela
			else:
				anim.play("walk_up")   # Y negativo sobe na tela
	else:
		anim.play("idle")
	var bodies = terror_aura.get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			var dist = global_position.distance_to(body.global_position)
			var intensity = remap(dist, 400,0.0,4.0,20.0)
			GameManager.increase_terror(intensity*delta)
			

# Função de teleporte atualizada
func teleport_near_player(safe_zone: float) -> void:
	var random_angle = randf() * TAU 
	
	# Ele vai surgir
	# depois da parede de luz, o que for maior. Isso garante que ele nunca caia na parte iluminada.
	var spawn_distance = max(400.0, safe_zone + 50.0)
	
	var offset = Vector2(cos(random_angle), sin(random_angle)) * spawn_distance
	global_position = player.global_position + offset
func _ready() -> void:
	# O monstro escuta dois sinais diferentes do Diretor
	GameManager.monster_awakened.connect(_on_monster_awakened)
	GameManager.difficulty_increased.connect(_on_difficulty_increased)

func _on_monster_awakened() -> void:
	is_active = true
	print("INIMIGO: Eu acordei...")

func _on_difficulty_increased(level: int) -> void:
	if level == 1:
		stalk_speed += 20.0  # Fica mais rápido na espreita
		hunt_speed += 40.0   # Fica mais letal na caça
		print("INIMIGO: Fiquei mais rápido (Nível 1)")
	elif level == 2:
		stalk_speed += 30.0  
		hunt_speed += 60.0   
		print("INIMIGO: MODO FÚRIA (Nível 2)")
