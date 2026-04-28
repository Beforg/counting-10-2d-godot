extends CharacterBody2D

enum State { HIDDEN, STALKING, HUNTING }
var current_state: State = State.HIDDEN
var is_active: bool = false # Começa dormindo
@onready var anim = $AnimatedSprite2D
@export var stalk_speed: float = 60.0
@export var hunt_speed: float = 90.0
@export var base_light_radius: float = 25.0
@onready var terror_aura = $TerrorAura
@export var player: Node2D

# NOVA VARIÁVEL: Define se ele roda no sentido horário ou anti-horário
var circle_direction: int = 1 

func _physics_process(delta: float) -> void:
	if not is_active:
		anim.play("idle")
		return
		
	if player != null and player.get("torch") != null:
		var light = player.torch.texture_scale
		var distance = global_position.distance_to(player.global_position)
		var current_safe_zone = base_light_radius * light * 0.95
		
		# Se o jogador esbarrar no monstro, morre na hora, independente do estado!
		if distance <= 45.0:
			print("O jogador esbarrou no monstro nas sombras! Game Over.")
			GameManager.reset_game()
			get_tree().change_scene_to_file("res://game_over_screen.tscn")
			return # O 'return' para o código aqui e evita que ele tente se mover
		
		if distance > 500.0: 
			teleport_near_player(current_safe_zone)
			distance = global_position.distance_to(player.global_position)
			
		# --- 3. DEFINIÇÃO DE ESTADOS ---
		var is_furious = (current_state == State.HUNTING and GameManager.terror_level > 90.0)
		
		if GameManager.terror_level >= 98.00 or is_furious:
			current_state = State.HUNTING
			current_safe_zone = 0.0 # Ignora a luz totalmente
		elif light > 8.5:
			current_state = State.HIDDEN
		elif light > 4.5: 
			current_state = State.STALKING
		else:
			current_state = State.HUNTING
			current_safe_zone = 0.0
			
		# --- A AÇÃO ---
# --- A AÇÃO ---
		match current_state:
			
			State.HIDDEN:
				var dir = global_position.direction_to(player.global_position)
				visible = GameManager.terror_level > 25
				velocity = dir * stalk_speed * 0.4
				move_and_slide()
				
			State.STALKING:
				visible = true
				if GameManager.terror_level >= 98.00:
					current_safe_zone = 0.0
				else:
					current_safe_zone = base_light_radius * light * 0.8
				
				var dir = global_position.direction_to(player.global_position)
				
				# Respeita a parede de luz
				if distance > current_safe_zone:
					velocity = dir * stalk_speed
				elif distance < current_safe_zone - 10.0:
					velocity = -dir * (stalk_speed * 0.8)
				else:
					var tangent = dir.rotated(PI / 2 * circle_direction)
					velocity = tangent * (stalk_speed * 0.7) 
					if randf() < 0.02:
						circle_direction *= -1
				
				move_and_slide()
				
			State.HUNTING:
				visible = true
				
				# O BOTE: Se estiver longe, teleporta
				if distance > 200.0:
					teleport_near_player(current_safe_zone)
					# IMPORTANTE: Atualiza a distância após teleportar
					distance = global_position.distance_to(player.global_position)
				
				var dir = global_position.direction_to(player.global_position)
				velocity = dir * hunt_speed
				
				# Corre pra matar (Distância em 45.0 resolve a física)
				if distance > 45.0:
					move_and_slide()
				else:
					print("Pegou o jogador! Trocando para Game Over...")
					GameManager.reset_game()
					get_tree().change_scene_to_file("res://game_over_screen.tscn")
	# Lógica de Animações isolada para evitar bugar quando Hidden
	if current_state != State.HIDDEN:
		if velocity.length() > 0:
			if abs(velocity.x) > abs(velocity.y):
				anim.play("right")
				anim.flip_h = velocity.x < 0 
			else:
				if velocity.y > 0:
					anim.play("down") 
				else:
					anim.play("top")   
		else:
			anim.play("idle")
			
	var bodies = terror_aura.get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			var dist = global_position.distance_to(body.global_position)
			var intensity = remap(dist, 400, 0.0, 4.0, 20.0)
			GameManager.increase_terror(intensity * delta)

# Função de teleporte 
func teleport_near_player(safe_zone: float) -> void:
	var random_angle = randf() * TAU 
	# Distância ajustada: Ele aparece no limite da luz
	var spawn_distance = max(150.0, safe_zone + 20.0)
	
	var offset = Vector2(cos(random_angle), sin(random_angle)) * spawn_distance
	global_position = player.global_position + offset

func _ready() -> void:
	GameManager.monster_awakened.connect(_on_monster_awakened)
	GameManager.difficulty_increased.connect(_on_difficulty_increased)

func _on_monster_awakened() -> void:
	is_active = true
	print("INIMIGO: Eu acordei...")
	
	# --- O SUSTO DO DESPERTAR ---
	# Assim que acordar, teleporta para as costas do jogador na mesma hora!
	if player != null:
		var light = player.torch.texture_scale
		var current_safe_zone = base_light_radius * light * 0.8
		teleport_near_player(current_safe_zone)

func _on_difficulty_increased(level: int) -> void:
	if level == 1:
		stalk_speed += 15 
		print("INIMIGO: Fiquei mais rápido (Nível 1)")
	elif level == 2:
		stalk_speed += 5  
		hunt_speed += 20   
		print("INIMIGO: MODO FÚRIA (Nível 2)")
